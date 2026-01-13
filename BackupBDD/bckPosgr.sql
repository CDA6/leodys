-- Table : referents
CREATE TABLE IF NOT EXISTS referents (
    id VARCHAR(36) PRIMARY KEY, -- UUID sous forme de String
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    role VARCHAR(100) NOT NULL,
    category VARCHAR(100) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE DEFAULT NULL
);

-- Table : messages
CREATE TABLE IF NOT EXISTS messages (
    id VARCHAR(36) PRIMARY KEY,
    referent_id VARCHAR(36) NOT NULL,
    referent_name VARCHAR(255) NOT NULL,
    subject VARCHAR(255) NOT NULL,
    body TEXT NOT NULL,
    sent_at TIMESTAMP WITH TIME ZONE NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE DEFAULT NULL,
    
    CONSTRAINT fk_message_referent
        FOREIGN KEY (referent_id)
        REFERENCES referents (id)
        ON DELETE CASCADE
);

-- Index pour la performance de l'API de synchro
CREATE INDEX IF NOT EXISTS idx_referents_updated_at ON referents(updated_at);
CREATE INDEX IF NOT EXISTS idx_messages_updated_at ON messages(updated_at);
CREATE INDEX IF NOT EXISTS idx_messages_referent_id ON messages(referent_id);
