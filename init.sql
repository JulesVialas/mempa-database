-- ============================================================
-- INITIALISATION
-- ============================================================
DROP DATABASE IF EXISTS mempa_db;
CREATE DATABASE mempa_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE mempa_db;

-- ============================================================
-- STRUCTURE DES DONNÉES (LDD)
-- ============================================================

-- Table UTILISATEUR
-- Stockage des comptes utilisateurs.
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
    FULLTEXT INDEX idx_ft_recherche (nom, style)
) ENGINE=InnoDB;

-- Table MORCEAU
-- Catalogue des chansons comprenant le titre et l'artiste.
CREATE TABLE morceau (
    id INT AUTO_INCREMENT PRIMARY KEY,
    titre VARCHAR(150) NOT NULL,
    artiste VARCHAR(100) NOT NULL,
    CONSTRAINT uk_morceau_titre_artiste UNIQUE (titre, artiste)
) ENGINE=InnoDB;

-- Table CONTENU_PLAYLIST (Table d'association)
-- Lie les morceaux aux playlists avec leur position dans la playlist.
CREATE TABLE contenu_playlist (
    playlist_id INT NOT NULL,
    morceau_id INT NOT NULL,
    position INT NOT NULL,
    date_ajout TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (playlist_id, morceau_id),
    CONSTRAINT fk_contenu_playlist FOREIGN KEY (playlist_id) REFERENCES playlist(id) ON DELETE CASCADE,
    CONSTRAINT fk_contenu_morceau FOREIGN KEY (morceau_id) REFERENCES morceau(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Table PARTICIPATION
-- Trace qui a contribué à quelle playlist pour la v3.
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
-- ============================================================

-- ============================================================
-- JEU DE DONNÉES DE TEST (SEED DATA)
-- ============================================================
USE mempa_db;

-- 1. INSERTION DES UTILISATEURS
-- Mots de passe hashés fictifs pour l'exemple
INSERT INTO utilisateur (pseudo, email, mot_de_passe_hash) VALUES
('Alice_Rock', 'alice@example.com', '$2y$10$abcdef123456...'),
('Bob_Jazz', 'bob@example.com', '$2y$10$xyz789...'),
('Charlie_Pop', 'charlie@example.com', '$2y$10$lmnop456...');

-- 2. INSERTION DES MORCEAUX (CATALOGUE)
INSERT INTO morceau (titre, artiste) VALUES
-- Rock / Metal
('Bohemian Rhapsody', 'Queen'),
('Stairway to Heaven', 'Led Zeppelin'),
('Hotel California', 'Eagles'),
('Smells Like Teen Spirit', 'Nirvana'),
('Back in Black', 'AC/DC'),
-- Jazz / Chill
('Take Five', 'The Dave Brubeck Quartet'),
('So What', 'Miles Davis'),
('Fly Me to the Moon', 'Frank Sinatra'),
('What a Wonderful World', 'Louis Armstrong'),
-- Pop / Variété
('Thriller', 'Michael Jackson'),
('Shape of You', 'Ed Sheeran'),
('Rolling in the Deep', 'Adele'),
('Blinding Lights', 'The Weeknd'),
-- Electro / House
('Get Lucky', 'Daft Punk'),
('One More Time', 'Daft Punk'),
('Levels', 'Avicii'),
('Titanium', 'David Guetta'),
-- Hip Hop
('Lose Yourself', 'Eminem'),
('Empire State of Mind', 'Jay-Z'),
('Sicko Mode', 'Travis Scott');

-- 3. INSERTION DES PLAYLISTS
-- On suppose les IDs utilisateurs : 1=Alice, 2=Bob, 3=Charlie
INSERT INTO playlist (nom, style, nbre_clics, createur_id) VALUES
('Classiques du Rock', 'Rock', 150, 1),      -- Playlist d'Alice
('Jazz & Coffee', 'Jazz', 45, 2),             -- Playlist de Bob
('Soirée Samedi', 'Electro', 320, 3),         -- Playlist de Charlie
('Best of 80s', 'Pop', 89, 1),                -- Autre playlist d'Alice
('Running Motivation', 'Hip Hop', 210, 3);    -- Autre playlist de Charlie

-- 4. INSERTION DU CONTENU DES PLAYLISTS
-- Note : On utilise des sous-requêtes pour récupérer les IDs proprement,
-- mais on peut aussi mettre les IDs en dur si on connaît l'ordre d'insertion ci-dessus.

-- Remplissage : Classiques du Rock (ID 1)
INSERT INTO contenu_playlist (playlist_id, morceau_id, position) VALUES
(1, 1, 1), -- Bohemian Rhapsody
(1, 2, 2), -- Stairway to Heaven
(1, 4, 3), -- Smells Like Teen Spirit
(1, 5, 4); -- Back in Black

-- Remplissage : Jazz & Coffee (ID 2)
INSERT INTO contenu_playlist (playlist_id, morceau_id, position) VALUES
(2, 6, 1), -- Take Five
(2, 7, 2), -- So What
(2, 8, 3); -- Fly Me to the Moon

-- Remplissage : Soirée Samedi (ID 3)
INSERT INTO contenu_playlist (playlist_id, morceau_id, position) VALUES
(3, 14, 1), -- Get Lucky
(3, 15, 2), -- One More Time
(3, 10, 3), -- Thriller
(3, 17, 4); -- Titanium

-- Remplissage : Best of 80s (ID 4)
INSERT INTO contenu_playlist (playlist_id, morceau_id, position) VALUES
(4, 10, 1), -- Thriller
(4, 3, 2),  -- Hotel California
(4, 5, 3);  -- Back in Black

-- Remplissage : Running Motivation (ID 5)
INSERT INTO contenu_playlist (playlist_id, morceau_id, position) VALUES
(5, 18, 1), -- Lose Yourself
(5, 20, 2), -- Sicko Mode
(5, 13, 3); -- Blinding Lights

-- 5. INSERTION DES PARTICIPATIONS
-- Table qui lie les créateurs à leurs playlists, ou des contributeurs tiers.

-- Les créateurs participent d'office à leurs playlists
INSERT INTO participation (playlist_id, utilisateur_id) VALUES
(1, 1), -- Alice sur "Classiques du Rock"
(2, 2), -- Bob sur "Jazz & Coffee"
(3, 3), -- Charlie sur "Soirée Samedi"
(4, 1), -- Alice sur "Best of 80s"
(5, 3); -- Charlie sur "Running Motivation"

-- Ajoutons une collaboration : Bob (ID 2) a aidé Alice (ID 1) sur sa playlist Rock
INSERT INTO participation (playlist_id, utilisateur_id) VALUES
(1, 2);

-- Alice (ID 1) a ajouté un son dans la playlist Soirée de Charlie (ID 3)
INSERT INTO participation (playlist_id, utilisateur_id) VALUES
(3, 1);

-- ============================================================
-- FIN DU JEU DE DONNÉES
-- ============================================================