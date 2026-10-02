CREATE TABLE aeronaves (
	id SERIAL PRIMARY KEY,
	modelo VARCHAR(100) NOT NULL,
	codigo_cauda VARCHAR(10) NOT NULL UNIQUE,
	capacidade INT NOT NULL CHECK (capacidade > 0)
);

CREATE TABLE pilotos (
	id SERIAL PRIMARY KEY,
	nome VARCHAR(150) NOT NULL,
	codigo_anac VARCHAR(6) NOT NULL UNIQUE,
	horas_voo INT DEFAULT 0 CHECK (horas_voo >= 0)
);

CREATE TABLE voos (
	id SERIAL PRIMARY KEY,
	aeronave_id INT NOT NULL,
	FOREIGN KEY (aeronave_id) REFERENCES aeronaves(id),

	piloto_id INT NOT NULL,
	FOREIGN KEY (piloto_id) REFERENCES pilotos(id),

	numero_voo VARCHAR(20) NOT NULL,
	origem VARCHAR(100) NOT NULL,
	destino VARCHAR(100) NOT NULL,
	data_hora TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

	status VARCHAR(20) DEFAULT 'Agendado',
	CHECK (status IN ('Agendado', 'Em Voo', 'Concluido', 'Cancelado'))
);

CREATE TABLE passageiros (
	id SERIAL PRIMARY KEY,
	nome VARCHAR(150) NOT NULL,
	cpf VARCHAR(11) NOT NULL UNIQUE,
	email VARCHAR(150) NOT NULL UNIQUE
);

CREATE TABLE passagens (
	id SERIAL PRIMARY KEY,

	voo_id INT NOT NULL,
	FOREIGN KEY (voo_id) REFERENCES voos(id),

	passageiro_id INT NOT NULL,
	FOREIGN KEY (passageiro_id) REFERENCES passageiros(id),

	assento CHAR(4) NOT NULL,

	classe VARCHAR(20) DEFAULT 'Econômica',
	CHECK (classe IN ('Econômica', 'Executiva')),

	valor DECIMAL(10,2) NOT NULL CHECK (valor > 0)
);

INSERT INTO aeronaves (modelo, codigo_cauda, capacidade)
VALUES
('Aeronave 1', 'ABC-123', 180),
('Aeronave 2', 'DEF-456', 150),
('Aeronave 3', 'GHI-789', 130),
('Aeronave 4', 'JKL-101', 200),
('Aeronave 5', 'MNO-202', 250);

INSERT INTO pilotos (nome, codigo_anac, horas_voo)
VALUES
('João Mendes', 'AN1001', 5200),
('Ana Costa', 'AN1002', 4300),
('Lucas Pereira', 'AN1003', 6100),
('Marina Alves', 'AN1004', 3900),
('Pedro Martins', 'AN1005', 7200);

INSERT INTO voos (aeronave_id, piloto_id, numero_voo, origem, destino, data_hora, status)
VALUES
(1, 1, 'G31001', 'Florianópolis', 'São Paulo', '10-10-2026 08:00:00', 'Agendado'),
(2, 2, 'LA2202', 'São Paulo', 'Rio de Janeiro', '02-10-2026 10:30:00', 'Em Voo'),
(3, 3, 'AZ3303', 'Curitiba', 'Florianópolis', '01-10-2026 14:00:00', 'Concluido'),
(4, 4, 'G34404', 'Brasília', 'Recife', '12-10-2026 16:00:00', 'Cancelado'),
(5, 5, 'LA5505', 'Recife', 'Salvador', '15-10-2026 09:00:00', 'Agendado');

INSERT INTO passageiros (nome, cpf, email)
VALUES
('Carlos Ferreira', '12344567890', 'carlosf@gmail.com'),
('Marina Alves', '23455678901', 'marinaa@gmail.com'),
('Pietro Lima', '34566789012', 'pietrol@gmail.com'),
('Julia Souza', '45677890123', 'julias@gmail.com'),
('Rafael Oliveira', '56788901234', 'rafaelo@gmail.com');


INSERT INTO passagens
(voo_id, passageiro_id, assento, classe, valor)
VALUES
(1, 1, '12A', 'Executiva', 950.00),
(1, 2, '15B', 'Econômica', 420.00),
(2, 3, '03A', 'Executiva', 1100.00),
(3, 4, '18C', 'Econômica', 350.00),
(5, 5, '20D', 'Econômica', 500.00);


SELECT
    voos.numero_voo,
    voos.origem,
    voos.destino,
    aeronaves.modelo,
    pilotos.nome AS piloto
FROM voos
JOIN aeronaves
ON voos.aeronave_id = aeronaves.id
JOIN pilotos
ON voos.piloto_id = pilotos.id
WHERE voos.status IN ('Agendado', 'Em Voo');


SELECT
    classe,
    SUM(valor) AS total_arrecadado
FROM passagens
GROUP BY classe;


SELECT
    passageiros.nome AS passageiro,
    voos.numero_voo,
    passagens.assento,
    passagens.valor
FROM passagens
JOIN passageiros
ON passagens.passageiro_id = passageiros.id
JOIN voos
ON passagens.voo_id = voos.id
WHERE passagens.classe = 'Executiva'
AND passagens.valor > 800
ORDER BY passagens.valor DESC;


CREATE VIEW vw_painel_aeroporto AS
SELECT
    voos.numero_voo,
    voos.data_hora,
    voos.origem,
    voos.destino,
    aeronaves.modelo,
    aeronaves.codigo_cauda,
    voos.status
FROM voos
JOIN aeronaves
ON voos.aeronave_id = aeronaves.id;

SELECT * FROM vw_painel_aeroporto;


CREATE VIEW vw_faturamento_por_voo AS
SELECT
    voos.id AS voo_id,
    voos.numero_voo,
    voos.destino,
    COUNT(passagens.id) AS total_passageiros,
    COALESCE(SUM(passagens.valor), 0) AS receita_total
FROM voos
LEFT JOIN passagens
ON voos.id = passagens.voo_id
GROUP BY
    voos.id,
    voos.numero_voo,
    voos.destino;

SELECT * FROM vw_faturamento_por_voo;