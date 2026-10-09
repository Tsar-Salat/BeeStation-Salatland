/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { shallowDiffers } from 'common/react';
import { debounce } from 'common/timer';
import { Component, createRef } from 'react';

import { createLogger } from '../logging';
import { computeBoxProps } from './Box';

const logger = createLogger('ByondUi');

// Stack of currently allocated BYOND UI element ids.
const byondUiStack = [];

const createByondUiElement = (elementId) => {
  // Reserve an index in the stack
  const index = byondUiStack.length;
  byondUiStack.push(null);
  // Get a unique id
  const id = elementId || 'byondui_' + index;
  logger.log(`allocated '${id}'`);
  // Return a control structure
  return {
    render: (params, visible) => {
      logger.log(`rendering '${id}'`);
      byondUiStack[index] = id;
      params['is-visible'] = visible ? 'true' : 'false';
      Byond.winset(id, params);
    },
    move: (pos, visible) => {
      Byond.winset(id, {
        pos,
        'is-visible': visible ? 'true' : 'false',
      });
    },
    unmount: () => {
      logger.log(`hiding '${id}'`);
      // temporarily hides the element, in case the window wants to re-use it. it will be unmounted during window unload.
      Byond.winset(id, {
        'is-visible': 'false',
      });
    },
  };
};

// This is also called by the backend on suspend.
export const cleanupByondUIs = () => {
  // Cleanly unmount all UI elements
  for (let index = 0; index < byondUiStack.length; index++) {
    const id = byondUiStack[index];
    if (typeof id === 'string') {
      logger.log(`unmounting '${id}' (suspend/close/beforeunload)`);
      byondUiStack[index] = null;
      Byond.winset(id, {
        parent: '',
      });
    }
  }
};

window.addEventListener('beforeunload', cleanupByondUIs);
window.addEventListener('close', cleanupByondUIs);

/**
 * Get the bounding box of the DOM element in display-pixels.
 */
const getBoundingBox = (element) => {
  const pixelRatio = window.devicePixelRatio ?? 1;
  const rect = element.getBoundingClientRect();
  return {
    pos: [rect.left * pixelRatio, rect.top * pixelRatio],
    size: [
      (rect.right - rect.left) * pixelRatio,
      (rect.bottom - rect.top) * pixelRatio,
    ],
  };
};

const findScrollParent = (element) => {
  for (
    let parent = element.parentElement;
    parent;
    parent = parent.parentElement
  ) {
    const { overflowY } = getComputedStyle(parent);
    if (overflowY === 'auto' || overflowY === 'scroll') {
      return parent;
    }
  }
  return null;
};

/**
 * A BYOND control can't be partly clipped, so one partly scrolled out of view
 * is hidden rather than drawn over the rest of the window.
 */
const isScrolledIntoView = (element, scrollParent) => {
  if (!scrollParent) {
    return true;
  }
  const rect = element.getBoundingClientRect();
  const view = scrollParent.getBoundingClientRect();
  if (rect.height > view.height + 1 || rect.width > view.width + 1) {
    return true;
  }
  // A pixel of slack for sub-pixel rounding
  return (
    rect.top >= view.top - 1 &&
    rect.bottom <= view.bottom + 1 &&
    rect.left >= view.left - 1 &&
    rect.right <= view.right + 1
  );
};

/**
 * With followScroll, the control moves with its scrolling container,
 * and hides while partly scrolled out of view.
 */
export class ByondUi extends Component {
  constructor(props) {
    super(props);
    this.containerRef = createRef();
    this.byondUiElement = createByondUiElement(props.params?.id);
    this.handleResize = debounce(() => {
      this.forceUpdate();
    }, 100);
    this.handleScroll = () => {
      if (this.scrollFrame) {
        return;
      }
      this.scrollFrame = requestAnimationFrame(() => {
        this.scrollFrame = null;
        const element = this.containerRef.current;
        const box = getBoundingBox(element);
        this.byondUiElement.move(
          box.pos[0] + ',' + box.pos[1],
          isScrolledIntoView(element, this.scrollParent),
        );
      });
    };
  }

  shouldComponentUpdate(nextProps) {
    const { params: prevParams = {}, ...prevRest } = this.props;
    const { params: nextParams = {}, ...nextRest } = nextProps;
    return (
      shallowDiffers(prevParams, nextParams) ||
      shallowDiffers(prevRest, nextRest)
    );
  }

  componentDidMount() {
    if (this.props.followScroll) {
      this.scrollParent = findScrollParent(this.containerRef.current);
      this.scrollParent?.addEventListener('scroll', this.handleScroll);
    }
    window.addEventListener('resize', this.handleResize);
    this.componentDidUpdate();
    this.handleResize();
  }

  componentDidUpdate() {
    const { params = {} } = this.props;
    const element = this.containerRef.current;
    const box = getBoundingBox(element);
    logger.debug('bounding box', box);
    this.byondUiElement.render(
      {
        parent: Byond.windowId,
        ...params,
        pos: box.pos[0] + ',' + box.pos[1],
        size: box.size[0] + 'x' + box.size[1],
      },
      isScrolledIntoView(element, this.scrollParent),
    );
  }

  componentWillUnmount() {
    window.removeEventListener('resize', this.handleResize);
    this.scrollParent?.removeEventListener('scroll', this.handleScroll);
    cancelAnimationFrame(this.scrollFrame);
    this.byondUiElement.unmount();
  }

  render() {
    const { params, followScroll, ...rest } = this.props;
    return (
      <div ref={this.containerRef} {...computeBoxProps(rest)}>
        {/* Filler */}
        <div style={{ minHeight: '22px' }} />
      </div>
    );
  }
}
