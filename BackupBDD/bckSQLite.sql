-- Table : Referents
CREATE TABLE IF NOT EXISTS Referents (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT NOT NULL,
    role TEXT NOT NULL,
    category TEXT NOT NULL,
    updated_at TEXT NOT NULL, -- Format ISO-8601
    deleted_at TEXT           -- NULL ou Format ISO-8601
);

-- Table : Messages
CREATE TABLE IF NOT EXISTS Messages (
    id TEXT PRIMARY KEY,
    referent_id TEXT NOT NULL,
    referent_name TEXT NOT NULL,
    subject TEXT NOT NULL,
    body TEXT NOT NULL,
    sent_at TEXT NOT NULL,    -- Format ISO-8601
    updated_at TEXT NOT NULL, -- Format ISO-8601
    deleted_at TEXT,          -- NULL ou Format ISO-8601

    FOREIGN KEY (referent_id) REFERENCES Referents (id) ON DELETE CASCADE
);

-- Index pour accélérer les tris locaux
CREATE INDEX IF NOT EXISTS idx_messages_sent_at ON Messages(sent_at DESC);