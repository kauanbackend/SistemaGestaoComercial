
-- =====================================================
-- PROJETO: Sistema de Gestão Comercial
-- TECNOLOGIA: Microsoft SQL Server / T-SQL
-- DESCRIÇÃO: Criação do banco, tabelas e dados iniciais
-- =====================================================

-- 1. CRIAÇÃO DO BANCO DE DADOS

IF DB_ID('SistemaGestaoComercial') IS NULL
BEGIN
    CREATE DATABASE SistemaGestaoComercial;
END;
GO

USE SistemaGestaoComercial;
GO

-- 2. CRIAÇÃO DAS TABELAS

-- Tabela: Clientes
CREATE TABLE Clientes (
    IDCliente INT IDENTITY(1,1) PRIMARY KEY,
    Nome VARCHAR(100) NOT NULL,
    Email VARCHAR(150) NULL,
    Telefone VARCHAR(20) NULL
);
GO

-- Tabela: Categorias
CREATE TABLE Categorias (
    IDCategoria INT IDENTITY(1,1) PRIMARY KEY,
    NomeCategoria VARCHAR(100) NOT NULL UNIQUE
);
GO

-- Tabela: Produtos
CREATE TABLE Produtos (
    IDProduto INT IDENTITY(1,1) PRIMARY KEY,
    IDCategoria INT NOT NULL,
    NomeProduto VARCHAR(150) NOT NULL,
    PrecoAtual DECIMAL(10,2) NOT NULL
        CHECK (PrecoAtual >= 0),
    EstoqueAtual INT NOT NULL
        CHECK (EstoqueAtual >= 0),
    Ativo BIT NOT NULL DEFAULT 1,

    FOREIGN KEY (IDCategoria)
        REFERENCES Categorias(IDCategoria)
);
GO

-- Tabela: Pedidos
CREATE TABLE Pedidos (
    IDPedido INT IDENTITY(1,1) PRIMARY KEY,
    IDCliente INT NOT NULL,
    DataPedido DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    DataConclusao DATETIME2 NULL,

    StatusPedido VARCHAR(20) NOT NULL DEFAULT 'Aberto'
        CHECK (StatusPedido IN ('Aberto', 'Concluído', 'Cancelado')),

    FormaPagamento VARCHAR(20) NULL,

    StatusPagamento VARCHAR(12) NOT NULL DEFAULT 'Pendente'
        CHECK (StatusPagamento IN ('Pendente', 'Pago', 'Reembolsado')),

    FOREIGN KEY (IDCliente)
        REFERENCES Clientes(IDCliente)
);
GO

-- Tabela: ItensPedido
CREATE TABLE ItensPedido (
    IDItemPedido INT IDENTITY(1,1) PRIMARY KEY,
    IDPedido INT NOT NULL,
    IDProduto INT NOT NULL,
    Quantidade INT NOT NULL CHECK (Quantidade > 0),
    PrecoUnitario DECIMAL(10,2) NOT NULL
        CHECK (PrecoUnitario >= 0),

    FOREIGN KEY (IDPedido)
        REFERENCES Pedidos(IDPedido),

    FOREIGN KEY (IDProduto)
        REFERENCES Produtos(IDProduto),

    UNIQUE (IDPedido, IDProduto)
);
GO

-- 3. INSERÇÃO DOS DADOS INICIAIS

-- Clientes
INSERT INTO Clientes (Nome, Email, Telefone)
VALUES
    ('Ana Oliveira', 'ana.oliveira@email.com', '11987654321'),
    ('Bruno Santos', 'bruno.santos@email.com', '11976543210'),
    ('Camila Ferreira', 'camila.ferreira@email.com', '11965432109');
GO

-- Categorias
INSERT INTO Categorias (NomeCategoria)
VALUES
    ('Eletrônicos'),
    ('Informática'),
    ('Acessórios');
GO

-- Produtos
INSERT INTO Produtos (
    IDCategoria,
    NomeProduto,
    PrecoAtual,
    EstoqueAtual
)
VALUES
    (2, 'Teclado', 79.90, 20),
    (2, 'SSD 480GB', 249.90, 15),
    (3, 'Mouse sem fio', 59.90, 10),
    (1, 'Televisão', 1000.90, 5);
GO

-- Pedidos
INSERT INTO Pedidos (IDCliente)
VALUES
    (1),
    (2),
    (3);
GO

-- Itens dos pedidos
INSERT INTO ItensPedido (
    IDPedido,
    IDProduto,
    Quantidade,
    PrecoUnitario
)
VALUES
    (1, 1, 1, 79.90),
    (1, 3, 1, 59.90),
    (2, 2, 1, 249.90);
GO

-- =====================================================
-- FIM DO SCRIPT DE CRIAÇÃO E CARGA INICIAL
-- =====================================================
