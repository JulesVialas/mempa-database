-- ============================================================
-- 0. INITIALISATION
-- ============================================================
-- On repart d'une feuille blanche pour éviter les conflits
DROP DATABASE IF EXISTS mempa_db;
CREATE DATABASE mempa_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE mempa_db;

-- ============================================================
-- 1. STRUCTURE DES DONNÉES (DDL)
-- ============================================================

-- Table UTILISATEUR
-- Stockage des comptes.
CREATE TABLE utilisateur (
    id INT AUTO_INCREMENT PRIMARY KEY,
    pseudo VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    mot_de_passe_hash VARCHAR(255) NOT NULL,
    date_inscription TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_utilisateur_pseudo UNIQUE (pseudo),
    CONSTRAINT uk_utilisateur_email UNIQUE (email)
) ENGINE=InnoDB;

-- Table PLAYLIST
-- Contient les infos générales et l'index de recherche.
CREATE TABLE playlist (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    style VARCHAR(50) NOT NULL,
    nbre_clics INT DEFAULT 0,
    createur_id INT NOT NULL,
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_modification TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_playlist_createur FOREIGN KEY (createur_id) REFERENCES utilisateur(id) ON DELETE CASCADE,
    -- Index FullText pour la recherche performante (V2)
    FULLTEXT INDEX idx_ft_recherche (nom, style)
) ENGINE=InnoDB;

-- Table MORCEAU
-- Catalogue unique des chansons (Titre + Artiste).
CREATE TABLE morceau (
    id INT AUTO_INCREMENT PRIMARY KEY,
    titre VARCHAR(150) NOT NULL,
    artiste VARCHAR(100) NOT NULL,
    -- Empêche d'avoir deux fois le même morceau dans la base
    CONSTRAINT uk_morceau_titre_artiste UNIQUE (titre, artiste)
) ENGINE=InnoDB;

-- Table CONTENU_PLAYLIST (Table d'association)
-- Lie les morceaux aux playlists avec une notion d'ordre (position).
CREATE TABLE contenu_playlist (
    playlist_id INT NOT NULL,
    morceau_id INT NOT NULL,
    position INT NOT NULL, -- Géré par le Backend Node.js
    date_ajout TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (playlist_id, morceau_id),
    CONSTRAINT fk_contenu_playlist FOREIGN KEY (playlist_id) REFERENCES playlist(id) ON DELETE CASCADE,
    CONSTRAINT fk_contenu_morceau FOREIGN KEY (morceau_id) REFERENCES morceau(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Table PARTICIPATION
-- Trace qui a contribué à quelle playlist (V3).
CREATE TABLE participation (
    playlist_id INT NOT NULL,
    utilisateur_id INT NOT NULL,
    date_premiere_contrib TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_derniere_contrib TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (playlist_id, utilisateur_id),
    CONSTRAINT fk_participation_playlist FOREIGN KEY (playlist_id) REFERENCES playlist(id) ON DELETE CASCADE,
    CONSTRAINT fk_participation_user FOREIGN KEY (utilisateur_id) REFERENCES utilisateur(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ============================================================
-- FIN DU SCRIPT
-- Pas de procédures stockées : La logique est dans le Backend Node.js
-- ============================================================