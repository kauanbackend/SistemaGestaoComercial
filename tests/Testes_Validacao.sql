
-- ============================================================
-- PROJETO: Sistema de Gestão Comercial
-- ARQUIVO: Testes_Validacao.sql
-- TECNOLOGIA: Microsoft SQL Server / T-SQL
-- DESCRIÇÃO: Testes de regras de negócio e estoque
-- ============================================================

USE SistemaGestaoComercial;
GO

-- ============================================================
-- TESTE 1 - CONCLUIR PEDIDO COM ESTOQUE SUFICIENTE
-- ============================================================

BEGIN TRANSACTION;

-- Descontar os produtos do estoque
UPDATE Produtos
SET EstoqueAtual = Produtos.EstoqueAtual - ItensPedido.Quantidade
FROM Produtos
INNER JOIN ItensPedido
    ON Produtos.IDProduto = ItensPedido.IDProduto
WHERE ItensPedido.IDPedido = 1;

-- Concluir o pedido
UPDATE Pedidos
SET
    StatusPedido = 'Concluído',
    DataConclusao = SYSDATETIME()
WHERE IDPedido = 1;

-- Conferir o resultado
SELECT
    IDPedido,
    StatusPedido,
    DataConclusao
FROM Pedidos
WHERE IDPedido = 1;

SELECT
    NomeProduto,
    EstoqueAtual
FROM Produtos
WHERE IDProduto IN (1, 3);

ROLLBACK;
GO


-- ============================================================
-- TESTE 2 - IMPEDIR CONCLUSÃO DE PEDIDO VAZIO
-- ============================================================

BEGIN TRANSACTION;

IF NOT EXISTS (
    SELECT 1
    FROM ItensPedido
    WHERE IDPedido = 3
)
BEGIN
    PRINT 'Erro: nao e possivel concluir um pedido vazio.';
END
ELSE
BEGIN
    UPDATE Pedidos
    SET
        StatusPedido = 'Concluído',
        DataConclusao = SYSDATETIME()
    WHERE IDPedido = 3;

    PRINT 'Pedido concluido com sucesso.';
END;

SELECT
    IDPedido,
    StatusPedido
FROM Pedidos
WHERE IDPedido = 3;

ROLLBACK;
GO


-- ============================================================
-- TESTE 3 - IDENTIFICAR ESTOQUE INSUFICIENTE
-- ============================================================

BEGIN TRANSACTION;

DECLARE @QuantidadeSolicitada INT = 25;

IF EXISTS (
    SELECT 1
    FROM Produtos
    WHERE IDProduto = 1
      AND EstoqueAtual < @QuantidadeSolicitada
)
BEGIN
    PRINT 'Erro: estoque insuficiente para realizar a compra.';
END
ELSE
BEGIN
    PRINT 'Estoque suficiente para realizar a compra.';
END;

SELECT
    NomeProduto,
    EstoqueAtual
FROM Produtos
WHERE IDProduto = 1;

ROLLBACK;
GO


-- ============================================================
-- TESTE 4 - CANCELAR PEDIDO E DEVOLVER ESTOQUE
-- ============================================================

BEGIN TRANSACTION;

-- Simular a conclusão do pedido 1
UPDATE Produtos
SET EstoqueAtual = Produtos.EstoqueAtual - ItensPedido.Quantidade
FROM Produtos
INNER JOIN ItensPedido
    ON Produtos.IDProduto = ItensPedido.IDProduto
WHERE ItensPedido.IDPedido = 1;

UPDATE Pedidos
SET
    StatusPedido = 'Concluído',
    DataConclusao = SYSDATETIME()
WHERE IDPedido = 1;

-- Cancelar o pedido concluído
IF EXISTS (
    SELECT 1
    FROM Pedidos
    WHERE IDPedido = 1
      AND StatusPedido = 'Concluído'
)
BEGIN
    -- Devolver os produtos ao estoque
    UPDATE Produtos
    SET EstoqueAtual = Produtos.EstoqueAtual + ItensPedido.Quantidade
    FROM Produtos
    INNER JOIN ItensPedido
        ON Produtos.IDProduto = ItensPedido.IDProduto
    WHERE ItensPedido.IDPedido = 1;

    UPDATE Pedidos
    SET StatusPedido = 'Cancelado'
    WHERE IDPedido = 1;

    PRINT 'Pedido cancelado e estoque devolvido.';
END;

-- Conferir o resultado
SELECT
    IDPedido,
    StatusPedido
FROM Pedidos
WHERE IDPedido = 1;

SELECT
    NomeProduto,
    EstoqueAtual
FROM Produtos
WHERE IDProduto IN (1, 3);

ROLLBACK;
GO


-- ============================================================
-- TESTE 5 - IMPEDIR DEVOLUÇÃO DUPLICADA DE ESTOQUE
-- ============================================================

BEGIN TRANSACTION;

-- Simular um pedido já cancelado
UPDATE Pedidos
SET StatusPedido = 'Cancelado'
WHERE IDPedido = 1;

IF EXISTS (
    SELECT 1
    FROM Pedidos
    WHERE IDPedido = 1
      AND StatusPedido = 'Concluído'
)
BEGIN
    UPDATE Produtos
    SET EstoqueAtual = Produtos.EstoqueAtual + ItensPedido.Quantidade
    FROM Produtos
    INNER JOIN ItensPedido
        ON Produtos.IDProduto = ItensPedido.IDProduto
    WHERE ItensPedido.IDPedido = 1;

    UPDATE Pedidos
    SET StatusPedido = 'Cancelado'
    WHERE IDPedido = 1;

    PRINT 'Estoque devolvido.';
END
ELSE
BEGIN
    PRINT 'Erro: pedido ja cancelado ou nao concluido.';
END;

-- Conferir o resultado
SELECT
    IDPedido,
    StatusPedido
FROM Pedidos
WHERE IDPedido = 1;

SELECT
    NomeProduto,
    EstoqueAtual
FROM Produtos
WHERE IDProduto IN (1, 3);

ROLLBACK;
GO

-- ============================================================
-- FIM DOS TESTES DE VALIDAÇÃO
-- ============================================================
