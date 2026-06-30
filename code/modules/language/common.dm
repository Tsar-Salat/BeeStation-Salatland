// 'basic' language; spoken by default.
/datum/language/common
	name = "Solbind"
	desc = "In a vast and connected web of starships, knowledge it is this one. Solbind is a constructed standard that bonds humanity's scattered registries, docks and freight lanes into a single tongue; a working language of trade and administration reaching from Geminae out to the Auri frontier. "
	key = "0"
	flags = TONGUELESS_SPEECH | LANGUAGE_HIDE_ICON_IF_UNDERSTOOD | LANGUAGE_ALWAYS_SHOW_ICON_IF_NOT_UNDERSTOOD
	default_priority = 100
	chargen_category = LANGUAGE_CATEGORY_HUMAN
	chargen_priority = 100 // the standard; near-universal among the crew
	space_chance = 20
	sentence_chance = 0
	between_word_sentence_chance = 10
	between_word_space_chance = 75
	additional_syllable_low = 0
	additional_syllable_high = 0

	icon_state = "galcom"
	// Default namelist is the human namelist, and common is the human language, so might as well.
	// Feel free to remove this at some point because common can generate some pretty cool names.
	always_use_default_namelist = TRUE
	/**
	 * This list really long, mainly because I can't make up my mind about which mandarin syllables should be removed,
	 * and the english syllables had to be duplicated so that there is roughly a 50-50 weighting.
	 *
	 * Sources:
	 * http://www.sttmedia.com/syllablefrequency-english
	 * http://www.chinahighlights.com/travelguide/learning-chinese/pinyin-syllables.htm
	 */
	syllables = list(
		// each sublist has an equal chance of being picked, so each syllable has an equal chance of being english or chinese
		list(
			"a", "ai", "an", "ang", "ao", "ba", "bai", "ban", "bang", "bao", "bei", "ben", "beng", "bi", "bian", "biao",
			"bie", "bin", "bing", "bo", "bu", "ca", "cai", "can", "cang", "cao", "ce", "cei", "cen", "ceng", "cha", "chai",
			"chan", "chang", "chao", "che", "chen", "cheng", "chi", "chong", "chou", "chu", "chua", "chuai", "chuan", "chuang", "chui", "chun",
			"chuo", "ci", "cong", "cou", "cu", "cuan", "cui", "cun", "cuo", "da", "dai", "dan", "dang", "dao", "de", "dei",
			"den", "deng", "di", "dian", "diao", "die", "ding", "diu", "dong", "dou", "du", "duan", "dui", "dun", "duo", "e",
			"ei", "en", "er", "fa", "fan", "fang", "fei", "fen", "feng", "fo", "fou", "fu", "ga", "gai", "gan", "gang",
			"gao", "ge", "gei", "gen", "geng", "gong", "gou", "gu", "gua", "guai", "guan", "guang", "gui", "gun", "guo", "ha",
			"hai", "han", "hang", "hao", "he", "hei", "hen", "heng", "hm", "hng", "hong", "hou", "hu", "hua", "huai", "huan",
			"huang", "hui", "hun", "huo", "ji", "jia", "jian", "jiang", "jiao", "jie", "jin", "jing", "jiong", "jiu", "ju", "juan",
			"jue", "jun", "ka", "kai", "kan", "kang", "kao", "ke", "kei", "ken", "keng", "kong", "kou", "ku", "kua", "kuai",
			"kuan", "kuang", "kui", "kun", "kuo", "la", "lai", "lan", "lang", "lao", "le", "lei", "leng", "li", "lia", "lian",
			"liang", "liao", "lie", "lin", "ling", "liu", "long", "lou", "lu", "luan", "lun", "luo", "ma", "mai", "man", "mang",
			"mao", "me", "mei", "men", "meng", "mi", "mian", "miao", "mie", "min", "ming", "miu", "mo", "mou", "mu", "na",
			"nai", "nan", "nang", "nao", "ne", "nei", "nen", "neng", "ng", "ni", "nian", "niang", "niao", "nie", "nin", "ning",
			"niu", "nong", "nou", "nu", "nuan", "nuo", "o", "ou", "pa", "pai", "pan", "pang", "pao", "pei", "pen", "peng",
			"pi", "pian", "piao", "pie", "pin", "ping", "po", "pou", "pu", "qi", "qia", "qian", "qiang", "qiao", "qie", "qin",
			"qing", "qiong", "qiu", "qu", "quan", "que", "qun", "ran", "rang", "rao", "re", "ren", "reng", "ri", "rong", "rou",
			"ru", "rua", "ruan", "rui", "run", "ruo", "sa", "sai", "san", "sang", "sao", "se", "sei", "sen", "seng", "sha",
			"shai", "shan", "shang", "shao", "she", "shei", "shen", "sheng", "shi", "shou", "shu", "shua", "shuai", "shuan", "shuang", "shui",
			"shun", "shuo", "si", "song", "sou", "su", "suan", "sui", "sun", "suo", "ta", "tai", "tan", "tang", "tao", "te",
			"teng", "ti", "tian", "tiao", "tie", "ting", "tong", "tou", "tu", "tuan", "tui", "tun", "tuo", "wa", "wai", "wan",
			"wang", "wei", "wen", "weng", "wo", "wu", "xi", "xia", "xian", "xiang", "xiao", "xie", "xin", "xing", "xiong", "xiu",
			"xu", "xuan", "xue", "xun", "ya", "yan", "yang", "yao", "ye", "yi", "yin", "ying", "yong", "you", "yu", "yuan",
			"yue", "yun", "za", "zai", "zan", "zang", "zao", "ze", "zei", "zen", "zeng", "zha", "zhai", "zhan", "zhang", "zhao",
			"zhe", "zhei", "zhen", "zheng", "zhi", "zhong", "zhou", "zhu", "zhua", "zhuai", "zhuan", "zhuang", "zhui", "zhun", "zhuo", "zi",
			"zong", "zou", "zuan", "zui", "zun", "zuo", "zu",
		),
		list(
			"al", "an", "ar", "as", "at", "ea", "ed", "en", "er", "es", "ha", "he", "hi", "in", "is", "it",
			"le", "me", "nd", "ne", "ng", "nt", "on", "or", "ou", "re", "se", "st", "te", "th", "ti", "to",
			"ve", "wa", "all", "and", "are", "but", "ent", "era", "ere", "eve", "for", "had", "hat", "hen", "her", "hin",
			"his", "ing", "ion", "ith", "not", "ome", "oul", "our", "sho", "ted", "ter", "tha", "the", "thi",
		),
	)

	// ─── The human-web intelligibility model (the design contract for every mutual_understanding list) ───
	// Comprehension ≈ modest structural overlap + a large Solbind broadcast-exposure bonus. Solbind is the
	// administrative *broadcast* tongue everyone is exposed to, so every human register understands Solbind
	// well (inbound 55-85) while Solbind itself follows the working dialects poorly (outbound 15-45). Bands:
	//   dialect->standard 85 (Aurin) · broadcast inbound 55-70 · broadcast outbound 15-45 · adjacent
	//   register (same social stratum) 35-40 · distant register (cross-stratum) ~20 · foreign heritage
	//   (Sertan) 10-15 · pidgin flat-bridge (Driftspeak out) flat 25 / +10 sibling Dredge / 55 Solbind ·
	//   lizard kin 45/40. The lizard tongues (Draconic/Vraksh) are an isolated kin island: NO human tongue
	//   partially understands them and they understand no human tongue - lizards work the human web via
	//   Aurin learned as a full L2. Enforced by /datum/unit_test/language_web_model; lore in the compendium.
	// The list below is Solbind's own *broadcast-outbound* row, so every value is deliberately low.
	mutual_understanding = list(
		/datum/language/aurin = 45,        // closest (Aurin is Solbind + jargon), but still outbound-capped
		/datum/language/dredge = 25,
		/datum/language/indolic = 20,
		/datum/language/driftspeak = 20,
		/datum/language/uncommon = 15,
		// No Draconic: it's an isolated lizard-family tongue; a human only gets it by learning it outright.
	)
