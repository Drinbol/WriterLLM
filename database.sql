-- 创建 Folders 表,用于存储文件夹信息
CREATE TABLE `Folders` (
                           `folder_id` int NOT NULL AUTO_INCREMENT,
                           `folder_name` VARCHAR(255) NOT NULL,
                           `parent_folder_id` int DEFAULT NULL, -- 可选的父文件夹ID,用于实现文件夹的嵌套
                           PRIMARY KEY (`folder_id`),
                           INDEX `idx_parent_folder_id` (`parent_folder_id`)
);

-- 修改 Books 表,增加 folder_id 字段,链接到 Folders 表
CREATE TABLE `Books` (
                         `book_id` int NOT NULL AUTO_INCREMENT,
                         `title` VARCHAR(255) NOT NULL,
                         `description` TEXT,
                         `author` VARCHAR(255) DEFAULT NULL,
                         `source` VARCHAR(255) DEFAULT NULL,
                         `url` VARCHAR(255) DEFAULT NULL,
                         `cover_image` VARCHAR(255) DEFAULT NULL,
                         `folder_id` int DEFAULT NULL, -- 链接到 Folders 表
                         `word_count` INT DEFAULT 0, -- 书籍的总字数
                         `chapter_count` INT DEFAULT 0, -- 书籍的总章节数
                         `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
                         `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                         PRIMARY KEY (`book_id`),
                         INDEX `idx_title` (`title`),
                         INDEX `idx_folder_id` (`folder_id`),
                         FOREIGN KEY (`folder_id`) REFERENCES `Folders` (`folder_id`) ON DELETE SET NULL -- 如果文件夹被删除,书籍的 folder_id 将被设置为 NULL
);

-- 创建 Chapter 表,包括章节号和时间戳
CREATE TABLE `Chapter` (
                           `chapter_id` int NOT NULL AUTO_INCREMENT, --  chapter_id 作为主键
                           `book_id` int NOT NULL,
                           `chapter_number` int NOT NULL,
                           `chapter_name` varchar(255) NOT NULL,
                           `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
                           `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                           PRIMARY KEY (`chapter_id`),
                           INDEX `idx_book_id_chapter_number` (`book_id`, `chapter_number`), -- 复合索引
                           FOREIGN KEY (`book_id`) REFERENCES `Books` (`book_id`)
);

-- 创建 ChapterBranches 表,包括分支名、描述和默认标志
CREATE TABLE `ChapterBranches` (
                                   `branch_id` int NOT NULL AUTO_INCREMENT,
                                   `chapter_id` int NOT NULL,
                                   `branch_name` varchar(255) NOT NULL,
                                   `description` text,
                                   `is_default` BOOLEAN NOT NULL DEFAULT FALSE,
                                   `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                   `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                                   PRIMARY KEY (`branch_id`),
                                   INDEX `idx_chapter_id` (`chapter_id`),
                                   FOREIGN KEY (`chapter_id`) REFERENCES `Chapter` (`chapter_id`),
                                   UNIQUE `uniq_chapter_id_is_default` (`chapter_id`, `is_default`) -- 唯一约束
);

-- 创建 ChapterVersions 表,包括版本号、内容、字数、Token数、初始标志
CREATE TABLE `ChapterVersions` (
                                   `version_id` int NOT NULL AUTO_INCREMENT,
                                   `branch_id` int NOT NULL,
                                   `version_number` int NOT NULL,
                                   `content` text NOT NULL,
                                   `word_count` int NOT NULL,
                                   `token_count` int NOT NULL,
                                   `is_initial` BOOLEAN NOT NULL DEFAULT FALSE,
                                   `audio_url` VARCHAR(255), -- 音频文件 URL
                                   `audio_duration` int, -- 音频时长,单位秒
                                   `ssml_content` TEXT, -- SSML 标记内容
                                   `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                   `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                                   PRIMARY KEY (`version_id`),
                                   INDEX `idx_branch_id_version_number` (`branch_id`, `version_number`), -- 复合索引
                                   FOREIGN KEY (`branch_id`) REFERENCES `ChapterBranches` (`branch_id`)
);

-- 创建 EntityType 表
CREATE TABLE `EntityType` (
                              `type_id` int NOT NULL AUTO_INCREMENT,
                              `type_name` VARCHAR(255) NOT NULL UNIQUE,
                              PRIMARY KEY (`type_id`)
);

-- 创建 Entities 表,用于存储书中的各种实体如人物、地点和物品
CREATE TABLE `Entities` (
                            `entity_id` int NOT NULL AUTO_INCREMENT,
                            `book_id` int NOT NULL,
                            `entity_type_id` int NOT NULL,
                            `name` VARCHAR(255) NOT NULL,
                            `description` TEXT,
                            `positive_prompt` TEXT, -- 正向 prompt
                            `negative_prompt` TEXT, -- 反向 prompt
                            `image_url` VARCHAR(255), -- 实体图片 URL
                            PRIMARY KEY (`entity_id`),
                            INDEX `idx_book_id` (`book_id`),
                            INDEX `idx_entity_type_id` (`entity_type_id`),
                            FOREIGN KEY (`book_id`) REFERENCES `Books` (`book_id`),
                            FOREIGN KEY (`entity_type_id`) REFERENCES `EntityType` (`type_id`)
);

-- 创建 WorldSettings 表,用于存储与每本书相关的世界设定
CREATE TABLE `WorldSettings` (
                                 `setting_id` int NOT NULL AUTO_INCREMENT,
                                 `book_id` int NOT NULL,
                                 `description` text,
                                 PRIMARY KEY (`setting_id`),
                                 INDEX `idx_book_id` (`book_id`),
                                 FOREIGN KEY (`book_id`) REFERENCES `Books` (`book_id`)
);

-- 创建 AIModelConfigs 表,存储 AI 模型配置
CREATE TABLE `AIModelConfigs` (
                                  `config_id` int NOT NULL AUTO_INCREMENT,
                                  `api_type` ENUM('LLM', 'TextToImage', 'ImageToImage', 'AudioToText', 'TextToAudio') NOT NULL,
                                  `provider_name` VARCHAR(255) NOT NULL,
                                  `model_name` VARCHAR(255) NOT NULL,
                                  `description` TEXT,
                                  `api_endpoint` VARCHAR(255),
                                  `api_key` VARCHAR(255),
                                  `parameters` JSON, -- 存储模型的各种参数
                                  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                                  PRIMARY KEY (`config_id`),
                                  INDEX `idx_api_type_provider_name_model_name` (`api_type`, `provider_name`, `model_name`) -- 复合索引
);

CREATE TABLE `Prompts` (
                           `prompt_id` INT NOT NULL AUTO_INCREMENT,
                           `entity_type_id` INT NOT NULL,
                           `prompt_name` VARCHAR(255) NOT NULL,
                           `prompt_type` ENUM('PositivePrompt', 'NegativePrompt') NOT NULL,
                           `content` TEXT NOT NULL,
                           `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                           `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                           PRIMARY KEY (`prompt_id`),
                           INDEX `idx_entity_type_id_prompt_type` (`entity_type_id`, `prompt_type`), -- 复合索引
                           FOREIGN KEY (`entity_type_id`) REFERENCES `EntityType` (`type_id`)
);

-- 素材表
CREATE TABLE `Materials` (
                             `material_id` int NOT NULL AUTO_INCREMENT,
                             `content` text NOT NULL,
                             `source` varchar(255), -- 素材来源,如书名、网址等
                             `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
                             `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                             PRIMARY KEY (`material_id`)
);

-- 标签表
CREATE TABLE `Tags` (
                        `tag_id` int NOT NULL AUTO_INCREMENT,
                        `name` varchar(50) NOT NULL,
                        `type` varchar(20) NOT NULL,
                        PRIMARY KEY (`tag_id`),
                        UNIQUE KEY `uniq_name` (`name`),
                        INDEX `idx_type` (`type`)
);

-- 素材-标签关联表
CREATE TABLE `MaterialTags` (
                                `material_id` int NOT NULL,
                                `tag_id` int NOT NULL,
                                PRIMARY KEY (`material_id`,`tag_id`),
                                INDEX `idx_tag_id` (`tag_id`),
                                FOREIGN KEY (`material_id`) REFERENCES `Materials` (`material_id`) ON DELETE CASCADE,
                                FOREIGN KEY (`tag_id`) REFERENCES `Tags` (`tag_id`) ON DELETE CASCADE
);

-- 素材-章节关联表
CREATE TABLE `MaterialChapters` (
                                    `material_id` int NOT NULL,
                                    `version_id` int NOT NULL,
                                    `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
                                    PRIMARY KEY (`material_id`, `version_id`),
                                    INDEX `idx_version_id` (`version_id`),
                                    FOREIGN KEY (`material_id`) REFERENCES `Materials` (`material_id`) ON DELETE CASCADE,
                                    FOREIGN KEY (`version_id`) REFERENCES `ChapterVersions` (`version_id`) ON DELETE CASCADE
);

-- 创建 GPUProviders 表,存储 GPU 服务器提供商信息
CREATE TABLE `GPUProviders` (
                                `provider_id` INT NOT NULL AUTO_INCREMENT,
                                `name` VARCHAR(255) NOT NULL,
                                `description` TEXT,
                                `api_endpoint` VARCHAR(255),
                                `api_key` VARCHAR(255),
                                `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                                `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                                PRIMARY KEY (`provider_id`)
);


-- 插入 Folders 表数据
INSERT INTO `Folders` (`folder_name`) VALUES ('科幻小说'), ('玄幻小说'), ('历史小说');

-- 插入 Books 表数据
INSERT INTO `Books` (`title`, `description`, `author`, `folder_id`) VALUES
                                                                        ('三体', '地球往事三部曲', '刘慈欣', 1),
                                                                        ('球状闪电', '一部硬科幻作品', '刘慈欣', 1),
                                                                        ('斗破苍穹', '天才少年的奇幻冒险', '天蚕土豆', 2),
                                                                        ('明朝那些事儿', '明朝历史的故事化讲述', '当年明月', 3);

-- 插入 Chapter 表数据
INSERT INTO `Chapter` (`book_id`, `chapter_number`, `chapter_name`) VALUES
                                                                        (1, 1, '第一章 科学边界'), (1, 2, '第二章 台球'), (1, 3, '第三章 摩尔定律'),
                                                                        (2, 1, '第一章 死亡屏障'), (2, 2, '第二章 超弦空间'),
                                                                        (3, 1, '第一章 陨落的天才'), (3, 2, '第二章 斗气大陆'),
                                                                        (4, 1, '第一章 夜宴'), (4, 2, '第二章 鸿胪寺之变');

-- 插入 EntityType 表数据
INSERT INTO `EntityType` (`type_name`) VALUES ('人物'), ('地点'), ('物品'), ('组织');

-- 插入 Entities 表数据
INSERT INTO `Entities` (`book_id`, `entity_type_id`, `name`, `description`) VALUES
                                                                                (1, 1, '叶文洁', '中国航天学家,地球三体组织成员'),
                                                                                (1, 2, '三体世界', '三颗太阳的世界,三体人的家园'),
                                                                                (2, 3, '球状闪电', '由高能粒子构成的球状闪电'),
                                                                                (3, 1, '萧炎', '斗气大陆天才少年'),
                                                                                (4, 4, '东厂', '明朝锦衣卫的前身');

-- 插入 AIModelConfigs 表数据
INSERT INTO `AIModelConfigs` (`api_type`, `provider_name`, `model_name`, `api_endpoint`, `api_key`) VALUES
                                                                                                        ('LLM', 'OpenAI', 'GPT-3', 'https://api.openai.com/v1/completions', 'your_api_key'),
                                                                                                        ('TextToImage', 'Anthropic', 'Claude', 'https://api.anthropic.com', 'your_api_key');

-- 插入 Prompts 表数据
INSERT INTO `Prompts` (`entity_type_id`, `prompt_name`,`prompt_type`, `content`) VALUES
                                                                                     (1, '1girl','PositivePrompt', '1girl, solo, smiling, school uniform, outdoors'),
                                                                                     (1, 'nonsfw','NegativePrompt', 'nsfw, lowres, bad anatomy, text, error, worst quality, low quality, normal quality, jpeg artifacts, signature, watermark, username, blurry'),
                                                                                     (2, 'landscape','PositivePrompt', 'landscape, mountain, river, forest, blue sky, white clouds'),
                                                                                     (2, 'nobuildings','NegativePrompt', 'buildings, humans, animals, text, signature, watermark');

-- 插入 Materials 表数据
INSERT INTO `Materials` (`content`, `source`) VALUES
                                                  ('材料1:人工智能是一个令人着迷的话题...', '科技杂志2023年第3期'),
                                                  ('材料2:未来人类社会将面临严峻的环境挑战', '环境学专著《危机与希望》');

-- 插入 Tags 表数据
INSERT INTO `Tags` (`name`, `type`) VALUES
                                        ('科幻元素', 'genre'), ('魔法', 'genre'),
                                        ('明朝', 'topic'), ('环境', 'topic');

-- 插入 MaterialTags 表数据
INSERT INTO `MaterialTags` (`material_id`, `tag_id`)
SELECT m.material_id, t.tag_id
FROM (
         SELECT 1 AS material_id, '科幻元素' AS tag_name
         UNION ALL
         SELECT 2, '环境'
     ) AS m
         JOIN `Tags` AS t ON m.tag_name = t.name;

-- 插入 GPUProviders 表数据
INSERT INTO `GPUProviders` (`name`, `api_endpoint`, `api_key`) VALUES
                                                                   ('NVidia', 'https://api.nvidia.com', 'your_api_key'),
                                                                   ('Google Colab', 'https://colab.research.google.com', 'your_api_key');
