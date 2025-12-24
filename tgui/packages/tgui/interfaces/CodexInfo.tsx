/* eslint-disable react/no-danger */
import { useEffect, useRef, useState } from 'react';

import { useBackend } from '../backend';
import {
  Box,
  Button,
  Divider,
  Icon,
  Input,
  Section,
  Stack,
  Tabs,
} from '../components';
import { Window } from '../layouts';

const COLOR_LORE = '#abdb9b'; // Light green for lore text
const COLOR_MECHANICS = '#97b3da'; // Light blue for mechanics text
const COLOR_ANTAG = '#de7a7a'; // Light red for antag text

type Category = {
  name: string;
  desc: string;
  key: string;
};

type CategoryItem = {
  name: string;
  key: string;
};

type CodexData = {
  entry_name: string;
  lore_text: string;
  mechanics_text: string;
  antag_text: string;
  is_antag: number;
  categories: Category[];
  category_items: CategoryItem[];
  search_results: CategoryItem[];
  search_text: string;
  view_mode: 'nexus' | 'category' | 'entry' | 'search';
  mode: number;
};

enum MODE {
  lore,
  info,
}

const CATEGORY_ICONS = {
  Species: 'user',
  'Factions and Culture': 'flag',
  Languages: 'language',
  Materials: 'cubes',
  Reagents: 'flask',
  Recipes: 'utensils',
  Gases: 'wind',
} as const;

export const CodexInfo = (_props) => {
  const { act, data } = useBackend<CodexData>();
  const {
    entry_name,
    lore_text,
    mechanics_text,
    antag_text,
    is_antag,
    categories,
    category_items,
    search_results,
    search_text,
    view_mode,
    mode,
  } = data;

  const [selectedCategory, setSelectedCategory] = useState<string | null>(null);
  const [localSearchText, setLocalSearchText] = useState(search_text || '');
  const [previousView, setPreviousView] = useState<{
    mode: string;
    category?: string;
  } | null>(null);
  const prevViewModeRef = useRef(view_mode);

  // Clear previousView when we transition away from entry view
  useEffect(() => {
    if (prevViewModeRef.current === 'entry' && view_mode !== 'entry') {
      setPreviousView(null);
    }
    prevViewModeRef.current = view_mode;
  }, [view_mode]);

  // Determine what to show based on view mode
  const showCategoryList =
    view_mode === 'nexus' ||
    view_mode === 'category' ||
    view_mode === 'search' ||
    (view_mode === 'entry' && previousView !== null);
  const showEntryContent =
    view_mode === 'entry' && (lore_text || mechanics_text);

  const handleViewEntry = (key: string) => {
    // Store current view before navigating
    if (view_mode === 'category') {
      setPreviousView({
        mode: 'category',
        category: selectedCategory || undefined,
      });
    } else if (view_mode === 'search') {
      setPreviousView({ mode: 'search' });
    }
    act('view_entry', { key });
  };

  const handleBack = () => {
    if (previousView) {
      // Don't clear previousView here - let the useEffect handle it when view_mode changes
      if (previousView.mode === 'category' && previousView.category) {
        act('view_entry', { key: previousView.category });
      } else if (previousView.mode === 'search') {
        act('search', { text: localSearchText });
      }
    }
  };

  return (
    <Window width={800} height={600} theme="neutral">
      <Window.Content>
        <Stack fill>
          {/* Left side - Navigation and Categories */}
          {showCategoryList && (
            <Stack.Item width="240px">
              <Stack fill vertical>
                {/* Header with navigation */}
                <Stack.Item>
                  <Section>
                    <Stack>
                      <Stack.Item>
                        <Button
                          icon="home"
                          onClick={() => {
                            act('home');
                            setSelectedCategory(null);
                            setLocalSearchText('');
                          }}
                          tooltip="Return to Codex home"
                        >
                          Home
                        </Button>
                      </Stack.Item>
                      <Stack.Item grow>
                        <Input
                          placeholder="Search codex..."
                          value={localSearchText}
                          onInput={(e, value) => setLocalSearchText(value)}
                          onEnter={(e, value) => act('search', { text: value })}
                          fluid
                        />
                      </Stack.Item>
                    </Stack>
                  </Section>
                </Stack.Item>

                {/* Categories list */}
                <Stack.Item grow>
                  <Section fill scrollable title="Categories">
                    <Tabs vertical>
                      {categories.map((category) => (
                        <Tabs.Tab
                          key={category.key}
                          selected={
                            selectedCategory === category.key ||
                            entry_name === category.name + ' (category)'
                          }
                          onClick={() => {
                            setSelectedCategory(category.key);
                            setPreviousView(null);
                            act('view_entry', { key: category.key });
                          }}
                        >
                          <Stack>
                            <Stack.Item width="18px" textAlign="center">
                              <Icon
                                name={CATEGORY_ICONS[category.name] || 'book'}
                              />
                            </Stack.Item>
                            <Stack.Item grow>{category.name}</Stack.Item>
                          </Stack>
                        </Tabs.Tab>
                      ))}
                    </Tabs>
                  </Section>
                </Stack.Item>

                {/* Mode toggle buttons */}
                <Stack.Item>
                  <Stack textAlign="center">
                    <Stack.Item grow>
                      <Button.Checkbox
                        fluid
                        lineHeight={2}
                        content="Lore"
                        checked={mode === MODE.lore}
                        icon="book"
                        style={{
                          border:
                            '2px solid ' +
                            (mode === MODE.lore ? '#20b142' : '#333'),
                        }}
                        onClick={() => {
                          if (mode === MODE.lore) {
                            return;
                          }
                          setSelectedCategory(null);
                          setPreviousView(null);
                          act('toggle_mode');
                        }}
                      />
                    </Stack.Item>
                    <Stack.Item grow>
                      <Button.Checkbox
                        fluid
                        lineHeight={2}
                        content="Info"
                        checked={mode === MODE.info}
                        icon="info-circle"
                        style={{
                          border:
                            '2px solid ' +
                            (mode === MODE.info ? '#20b142' : '#333'),
                        }}
                        onClick={() => {
                          if (mode === MODE.info) {
                            return;
                          }
                          setSelectedCategory(null);
                          setPreviousView(null);
                          act('toggle_mode');
                        }}
                      />
                    </Stack.Item>
                  </Stack>
                </Stack.Item>
              </Stack>
            </Stack.Item>
          )}

          {/* Right pane - Content */}
          <Stack.Item grow>
            <Stack fill vertical>
              {/* Title bar */}
              <Stack.Item>
                <Section>
                  <Stack>
                    <Stack.Item grow>
                      <Box fontSize="1.1rem" bold>
                        {view_mode === 'category' && selectedCategory
                          ? categories.find((c) => c.key === selectedCategory)
                              ?.name || entry_name
                          : entry_name || 'Codex'}
                      </Box>
                    </Stack.Item>
                    {previousView && (
                      <Stack.Item>
                        <Button icon="arrow-left" onClick={handleBack}>
                          Back
                        </Button>
                      </Stack.Item>
                    )}
                  </Stack>
                </Section>
              </Stack.Item>

              {/* Content area */}
              <Stack.Item grow>
                <Section fill scrollable>
                  <Stack vertical>
                    {/* Show search results if searching */}
                    {view_mode === 'search' && (
                      <Stack.Item>
                        <Box bold mb={1}>
                          Search Results
                          {search_results && search_results.length > 0 && (
                            <> ({search_results.length} found)</>
                          )}
                        </Box>
                        {search_results && search_results.length > 0 ? (
                          <Box>
                            {search_results.map((item, index) => (
                              <Box key={item.key} inline>
                                <Button
                                  color="transparent"
                                  onClick={() => handleViewEntry(item.key)}
                                >
                                  {item.name}
                                </Button>
                                {index < search_results.length - 1 && (
                                  <Box inline> </Box>
                                )}
                              </Box>
                            ))}
                          </Box>
                        ) : (
                          <Box color="gray" italic>
                            No results found for &quot;{search_text}&quot;
                          </Box>
                        )}
                      </Stack.Item>
                    )}

                    {/* Show category items if viewing a category */}
                    {view_mode === 'category' &&
                      selectedCategory === entry_name && (
                        <>
                          {/* Show lore text if available */}
                          {!!lore_text && (
                            <Stack.Item>
                              <Box color={COLOR_LORE} mb={2}>
                                {/* eslint-disable-next-line react/no-danger */}
                                <div
                                  dangerouslySetInnerHTML={{
                                    __html: lore_text,
                                  }}
                                />
                              </Box>
                            </Stack.Item>
                          )}
                          {/* Show category items */}
                          {category_items && category_items.length > 0 && (
                            <Stack.Item>
                              <Stack vertical>
                                {category_items.map((item) => (
                                  <Stack.Item key={item.key}>
                                    <Button
                                      color="transparent"
                                      onClick={() => handleViewEntry(item.key)}
                                    >
                                      {item.name}
                                    </Button>
                                  </Stack.Item>
                                ))}
                              </Stack>
                            </Stack.Item>
                          )}
                        </>
                      )}

                    {/* Show entry content if viewing an entry */}
                    {showEntryContent && (
                      <>
                        {/* Lore text */}
                        {!!lore_text && (
                          <Stack.Item>
                            <Box color={COLOR_LORE}>
                              {/* eslint-disable-next-line react/no-danger */}
                              <div
                                dangerouslySetInnerHTML={{
                                  __html: lore_text,
                                }}
                              />
                            </Box>
                          </Stack.Item>
                        )}

                        {/* Mechanics text */}
                        {!!mechanics_text && (
                          <Stack.Item>
                            {!!lore_text && <Divider />}
                            <Box bold mb={1}>
                              OOC Information
                            </Box>
                            <Box color={COLOR_MECHANICS}>
                              {/* eslint-disable-next-line react/no-danger */}
                              <div
                                dangerouslySetInnerHTML={{
                                  __html: mechanics_text,
                                }}
                              />
                            </Box>
                          </Stack.Item>
                        )}

                        {/* Antag text (only visible to antags) */}
                        {!!antag_text && !!is_antag && (
                          <Stack.Item>
                            <Divider />
                            <Box bold mb={1}>
                              Antagonist Information
                            </Box>
                            <Box color={COLOR_ANTAG}>
                              {/* eslint-disable-next-line react/no-danger */}
                              <div
                                dangerouslySetInnerHTML={{
                                  __html: antag_text,
                                }}
                              />
                            </Box>
                          </Stack.Item>
                        )}
                      </>
                    )}

                    {/* Welcome message for Nexus */}
                    {view_mode === 'nexus' && (
                      <Stack.Item>
                        <Stack vertical>
                          <Stack.Item>
                            <Box fontSize="1.1rem" bold mb={2}>
                              Welcome to the Codex
                            </Box>
                          </Stack.Item>
                          <Stack.Item>
                            <Box mb={2}>
                              Select a category from the left to browse entries,
                              or use the search bar above.
                            </Box>
                          </Stack.Item>
                          <Stack.Item>
                            <Divider />
                          </Stack.Item>
                          <Stack.Item>
                            <Stack vertical>
                              <Stack.Item>
                                <Stack>
                                  <Stack.Item width="20px">
                                    <Icon name="circle" color={COLOR_LORE} />
                                  </Stack.Item>
                                  <Stack.Item grow>
                                    <Box color={COLOR_LORE}>
                                      Lore information (in-character knowledge)
                                    </Box>
                                  </Stack.Item>
                                </Stack>
                              </Stack.Item>
                              <Stack.Item>
                                <Stack>
                                  <Stack.Item width="20px">
                                    <Icon
                                      name="circle"
                                      color={COLOR_MECHANICS}
                                    />
                                  </Stack.Item>
                                  <Stack.Item grow>
                                    <Box color={COLOR_MECHANICS}>
                                      Mechanics information (out-of-character
                                      game help)
                                    </Box>
                                  </Stack.Item>
                                </Stack>
                              </Stack.Item>
                              {!!is_antag && (
                                <Stack.Item>
                                  <Stack>
                                    <Stack.Item width="20px">
                                      <Icon name="circle" color={COLOR_ANTAG} />
                                    </Stack.Item>
                                    <Stack.Item grow>
                                      <Box color={COLOR_ANTAG}>
                                        Antagonist information (only visible to
                                        antagonists)
                                      </Box>
                                    </Stack.Item>
                                  </Stack>
                                </Stack.Item>
                              )}
                            </Stack>
                          </Stack.Item>
                        </Stack>
                      </Stack.Item>
                    )}
                  </Stack>
                </Section>
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
