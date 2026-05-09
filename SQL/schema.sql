-- ============================================================
-- FluviaRP - Database Schema
-- Engine: MySQL / MariaDB
-- ============================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ------------------------------------------------------------
-- Players (one row per unique license identifier)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `players` (
    `id`           INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `identifier`   VARCHAR(60)  NOT NULL COMMENT 'license:xxxx ou steam:xxxx',
    `first_joined` TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `last_seen`    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uq_identifier` (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------
-- Characters (jusqu'à 3 slots par joueur)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `characters` (
    `id`          INT UNSIGNED     NOT NULL AUTO_INCREMENT,
    `player_id`   INT UNSIGNED     NOT NULL,
    `slot`        TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '1, 2 ou 3',
    `first_name`  VARCHAR(50)      NOT NULL,
    `last_name`   VARCHAR(50)      NOT NULL,
    `dob`         DATE             NOT NULL,
    `nationality` VARCHAR(80)      NOT NULL DEFAULT '',
    `gender`      TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '0=homme 1=femme',
    `appearance`  LONGTEXT         NOT NULL DEFAULT '{}' COMMENT 'JSON - apparence ped complète',
    `position`    TEXT             NOT NULL DEFAULT '{"x":-269.4,"y":-955.3,"z":31.2}',
    `is_dead`     TINYINT(1)       NOT NULL DEFAULT 0,
    `created_at`  TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at`  TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uq_slot` (`player_id`, `slot`),
    CONSTRAINT `fk_char_player` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------
-- Admin Roles
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `admin_roles` (
    `id`          INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `name`        VARCHAR(60)  NOT NULL,
    `label`       VARCHAR(100) NOT NULL,
    `permissions` LONGTEXT     NOT NULL COMMENT 'JSON array de nodes de permission',
    `created_at`  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uq_role_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Rôles par défaut
INSERT IGNORE INTO `admin_roles` (`name`, `label`, `permissions`) VALUES
('superadmin', 'Super Admin', '["*"]'),
('admin',      'Administrateur', '["players.kick","players.ban","players.teleport","players.teleport_to_me","players.god_mode","players.info","vehicles.spawn","vehicles.keys","noclip","god_mode","teleport.waypoint","factions.manage","roles.manage","server.settings"]'),
('moderateur', 'Modérateur',     '["players.kick","players.teleport","players.info"]');

-- ------------------------------------------------------------
-- Admin Assignments (joueur -> rôle)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `admin_assignments` (
    `id`          INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `player_id`   INT UNSIGNED NOT NULL,
    `role_id`     INT UNSIGNED NOT NULL,
    `assigned_by` INT UNSIGNED NULL,
    `assigned_at` TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uq_assignment` (`player_id`, `role_id`),
    CONSTRAINT `fk_assign_player` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_assign_role`   FOREIGN KEY (`role_id`)   REFERENCES `admin_roles` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------
-- Bans
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `bans` (
    `id`          INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `identifier`  VARCHAR(60)  NOT NULL,
    `reason`      TEXT         NOT NULL,
    `banned_by`   VARCHAR(60)  NOT NULL,
    `expires_at`  TIMESTAMP    NULL DEFAULT NULL COMMENT 'NULL = permanent',
    `created_at`  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_identifier` (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------
-- Factions
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `factions` (
    `id`           INT UNSIGNED     NOT NULL AUTO_INCREMENT,
    `name`         VARCHAR(60)      NOT NULL,
    `label`        VARCHAR(100)     NOT NULL,
    `type`         VARCHAR(40)      NOT NULL DEFAULT 'legal' COMMENT 'legal|illegal|civilian',
    `blip_sprite`  SMALLINT UNSIGNED NOT NULL DEFAULT 1,
    `blip_color`   TINYINT UNSIGNED  NOT NULL DEFAULT 0,
    `settings`     LONGTEXT         NOT NULL DEFAULT '{}' COMMENT 'JSON - paramètres supplémentaires',
    `created_at`   TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uq_faction_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------
-- Faction Grades / Rangs
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `faction_grades` (
    `id`         INT UNSIGNED     NOT NULL AUTO_INCREMENT,
    `faction_id` INT UNSIGNED     NOT NULL,
    `grade`      TINYINT UNSIGNED NOT NULL DEFAULT 0,
    `label`      VARCHAR(100)     NOT NULL,
    `is_boss`    TINYINT(1)       NOT NULL DEFAULT 0,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uq_grade` (`faction_id`, `grade`),
    CONSTRAINT `fk_grade_faction` FOREIGN KEY (`faction_id`) REFERENCES `factions` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------
-- Faction Outfits / Tenues
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `faction_outfits` (
    `id`         INT UNSIGNED     NOT NULL AUTO_INCREMENT,
    `faction_id` INT UNSIGNED     NOT NULL,
    `grade_id`   INT UNSIGNED     NULL COMMENT 'NULL = tous les grades',
    `label`      VARCHAR(100)     NOT NULL,
    `gender`     TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '0=homme 1=femme',
    `components` LONGTEXT         NOT NULL COMMENT 'JSON - composants/props GTA V',
    `created_at` TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    CONSTRAINT `fk_outfit_faction` FOREIGN KEY (`faction_id`) REFERENCES `factions` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------
-- Faction Service Points (points de prise de service)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `faction_service_points` (
    `id`         INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `faction_id` INT UNSIGNED NOT NULL,
    `label`      VARCHAR(100) NOT NULL,
    `x`          FLOAT        NOT NULL,
    `y`          FLOAT        NOT NULL,
    `z`          FLOAT        NOT NULL,
    `heading`    FLOAT        NOT NULL DEFAULT 0.0,
    `created_at` TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    CONSTRAINT `fk_sp_faction` FOREIGN KEY (`faction_id`) REFERENCES `factions` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------
-- Character Faction Membership (appartenance faction)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `character_factions` (
    `id`           INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `character_id` INT UNSIGNED NOT NULL,
    `faction_id`   INT UNSIGNED NOT NULL,
    `grade_id`     INT UNSIGNED NOT NULL,
    `on_duty`      TINYINT(1)   NOT NULL DEFAULT 0,
    `joined_at`    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uq_char_faction` (`character_id`, `faction_id`),
    CONSTRAINT `fk_cf_character` FOREIGN KEY (`character_id`) REFERENCES `characters` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_cf_faction`   FOREIGN KEY (`faction_id`)   REFERENCES `factions` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------
-- Inventories
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `inventories` (
    `id`         INT UNSIGNED     NOT NULL AUTO_INCREMENT,
    `owner_type` VARCHAR(20)      NOT NULL DEFAULT 'character' COMMENT 'character|vehicle|stash',
    `owner_id`   INT UNSIGNED     NOT NULL,
    `slots`      TINYINT UNSIGNED NOT NULL DEFAULT 30,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uq_owner` (`owner_type`, `owner_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------
-- Inventory Items
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `inventory_items` (
    `id`           INT UNSIGNED     NOT NULL AUTO_INCREMENT,
    `inventory_id` INT UNSIGNED     NOT NULL,
    `slot`         TINYINT UNSIGNED NOT NULL,
    `item_name`    VARCHAR(60)      NOT NULL,
    `amount`       SMALLINT UNSIGNED NOT NULL DEFAULT 1,
    `metadata`     LONGTEXT         NOT NULL DEFAULT '{}' COMMENT 'JSON - ex: {"plate":"ABC123"} pour clé de véhicule',
    `created_at`   TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uq_item_slot` (`inventory_id`, `slot`),
    CONSTRAINT `fk_item_inventory` FOREIGN KEY (`inventory_id`) REFERENCES `inventories` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

SET FOREIGN_KEY_CHECKS = 1;
