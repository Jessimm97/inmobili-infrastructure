-- Datos iniciales para la base de datos de inmobiliaria.
-- Este script es idempotente: se puede ejecutar varias veces sin duplicar registros.

CREATE TABLE IF NOT EXISTS properties (
    id BIGINT NOT NULL AUTO_INCREMENT,
    title VARCHAR(255) NOT NULL,
    location VARCHAR(255) NOT NULL,
    price VARCHAR(255) NOT NULL,
    description TEXT,
    bedrooms INT NOT NULL,
    bathrooms INT NOT NULL,
    stories INT NOT NULL,
    image_url VARCHAR(255),
    agent_id BIGINT,
    created_at DATETIME(6),
    PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS property_features (
    property_id BIGINT NOT NULL,
    feature VARCHAR(255),
    CONSTRAINT fk_property_features_property
        FOREIGN KEY (property_id) REFERENCES properties (id)
);

CREATE TABLE IF NOT EXISTS inquiries (
    id BIGINT NOT NULL AUTO_INCREMENT,
    client_name VARCHAR(255),
    client_email VARCHAR(255),
    client_phone VARCHAR(255),
    message TEXT,
    property_id BIGINT,
    created_at DATETIME(6),
    PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS agents (
    id BIGINT NOT NULL AUTO_INCREMENT,
    name VARCHAR(255),
    email VARCHAR(255),
    phone VARCHAR(255),
    photo_url VARCHAR(255),
    PRIMARY KEY (id)
);

INSERT INTO agents (name, email, phone, photo_url)
SELECT 'Ana Martínez', 'ana.martinez@example.com', '+34600555666', '/images/agent1.jpg'
WHERE NOT EXISTS (
    SELECT 1 FROM agents WHERE email = 'ana.martinez@example.com'
);

INSERT INTO agents (name, email, phone, photo_url)
SELECT 'Luis Fernández', 'luis.fernandez@example.com', '+34600777888', '/images/agent2.jpg'
WHERE NOT EXISTS (
    SELECT 1 FROM agents WHERE email = 'luis.fernandez@example.com'
);

INSERT INTO properties
    (title, location, price, description, bedrooms, bathrooms, stories, image_url, agent_id, created_at)
SELECT
    'Casa moderna con jardín',
    'Madrid, España',
    '$350000',
    'Vivienda moderna con jardín privado, garaje y amplios espacios interiores.',
    3, 2, 2,
    'https://images.unsplash.com/photo-1600585154340-be6161a56a0c',
    1, CURRENT_TIMESTAMP(6)
WHERE NOT EXISTS (
    SELECT 1 FROM properties
    WHERE title = 'Casa moderna con jardín' AND location = 'Madrid, España'
);

INSERT INTO properties
    (title, location, price, description, bedrooms, bathrooms, stories, image_url, agent_id, created_at)
SELECT
    'Apartamento céntrico',
    'Barcelona, España',
    '$245000',
    'Apartamento luminoso situado en el centro, cerca de transporte y servicios.',
    2, 1, 1,
    'https://images.unsplash.com/photo-1600607687920-4e2a09cf159d',
    1, CURRENT_TIMESTAMP(6)
WHERE NOT EXISTS (
    SELECT 1 FROM properties
    WHERE title = 'Apartamento céntrico' AND location = 'Barcelona, España'
);

INSERT INTO properties
    (title, location, price, description, bedrooms, bathrooms, stories, image_url, agent_id, created_at)
SELECT
    'Chalet familiar con piscina',
    'Valencia, España',
    '$520000',
    'Chalet independiente con piscina, terraza y zona ajardinada.',
    4, 3, 2,
    'https://images.unsplash.com/photo-1600566753190-17f0baa2a6c3',
    2, CURRENT_TIMESTAMP(6)
WHERE NOT EXISTS (
    SELECT 1 FROM properties
    WHERE title = 'Chalet familiar con piscina' AND location = 'Valencia, España'
);

INSERT INTO property_features (property_id, feature)
SELECT p.id, f.feature
FROM properties p
JOIN (
    SELECT 'Casa moderna con jardín' AS title, 'Jardín privado' AS feature
    UNION ALL SELECT 'Casa moderna con jardín', 'Garaje'
    UNION ALL SELECT 'Casa moderna con jardín', 'Cocina equipada'
    UNION ALL SELECT 'Apartamento céntrico', 'Ascensor'
    UNION ALL SELECT 'Apartamento céntrico', 'Balcón'
    UNION ALL SELECT 'Chalet familiar con piscina', 'Piscina privada'
    UNION ALL SELECT 'Chalet familiar con piscina', 'Terraza'
) f ON f.title = p.title
WHERE NOT EXISTS (
    SELECT 1 FROM property_features pf
    WHERE pf.property_id = p.id AND pf.feature = f.feature
);

INSERT INTO inquiries
    (client_name, client_email, client_phone, message, property_id, created_at)
SELECT
    'Laura García',
    'laura.garcia@example.com',
    '+34600111222',
    'Me gustaría concertar una visita a la propiedad.',
    p.id,
    CURRENT_TIMESTAMP(6)
FROM properties p
WHERE p.title = 'Casa moderna con jardín'
  AND NOT EXISTS (
      SELECT 1 FROM inquiries i
      WHERE i.client_email = 'laura.garcia@example.com'
        AND i.property_id = p.id
  );

INSERT INTO inquiries
    (client_name, client_email, client_phone, message, property_id, created_at)
SELECT
    'Carlos López',
    'carlos.lopez@example.com',
    '+34600333444',
    '¿El apartamento sigue disponible?',
    p.id,
    CURRENT_TIMESTAMP(6)
FROM properties p
WHERE p.title = 'Apartamento céntrico'
  AND NOT EXISTS (
      SELECT 1 FROM inquiries i
      WHERE i.client_email = 'carlos.lopez@example.com'
        AND i.property_id = p.id
  );
