
-- ============================================================
-- PROJETO: Sistema de Gestão Comercial
-- ARQUIVO: Consultas_SQL_SistemaGestaoComercial.sql
-- TECNOLOGIA: Microsoft SQL Server / T-SQL
-- DESCRIÇÃO: Consultas e relatórios do banco comercial
-- ============================================================

USE SistemaGestaoComercial;
GO

-- ============================================================
-- 01. CONSULTAS COM JOIN
-- ============================================================

-- 1.1 - Itens dos pedidos com informações dos produtos
SELECT
    ItensPedido.IDPedido,
    Produtos.NomeProduto,
    ItensPedido.Quantidade,
    ItensPedido.PrecoUnitario
FROM ItensPedido
INNER JOIN Produtos
    ON ItensPedido.IDProduto = Produtos.IDProduto;


-- 1.2 - Relatório detalhado de pedidos e clientes
SELECT
    Pedidos.IDPedido,
    Clientes.Nome AS Cliente,
    Produtos.NomeProduto,
    ItensPedido.Quantidade,
    ItensPedido.PrecoUnitario
FROM Pedidos
INNER JOIN Clientes
    ON Pedidos.IDCliente = Clientes.IDCliente
INNER JOIN ItensPedido
    ON Pedidos.IDPedido = ItensPedido.IDPedido
INNER JOIN Produtos
    ON ItensPedido.IDProduto = Produtos.IDProduto;


-- 1.3 - Clientes e seus pedidos, incluindo clientes sem pedidos
SELECT
    Clientes.Nome AS Cliente,
    Pedidos.IDPedido,
    Pedidos.StatusPedido
FROM Clientes
LEFT JOIN Pedidos
    ON Clientes.IDCliente = Pedidos.IDCliente;


-- ============================================================
-- 02. AGREGAÇÕES E AGRUPAMENTOS
-- ============================================================

-- 2.1 - Valor total dos itens por cliente
SELECT
    Clientes.Nome AS Cliente,
    COALESCE(
        SUM(ItensPedido.Quantidade * ItensPedido.PrecoUnitario),
        0
    ) AS ValorTotal
FROM Clientes
LEFT JOIN Pedidos
    ON Clientes.IDCliente = Pedidos.IDCliente
LEFT JOIN ItensPedido
    ON Pedidos.IDPedido = ItensPedido.IDPedido
GROUP BY Clientes.Nome;


-- 2.2 - Quantidade total de itens por cliente
SELECT
    Clientes.Nome AS Cliente,
    COALESCE(SUM(ItensPedido.Quantidade), 0) AS TotalItens
FROM Clientes
LEFT JOIN Pedidos
    ON Clientes.IDCliente = Pedidos.IDCliente
LEFT JOIN ItensPedido
    ON Pedidos.IDPedido = ItensPedido.IDPedido
GROUP BY Clientes.Nome;


-- 2.3 - Média, menor e maior preço dos produtos
SELECT
    AVG(PrecoAtual) AS PrecoMedio,
    MIN(PrecoAtual) AS MenorPreco,
    MAX(PrecoAtual) AS MaiorPreco
FROM Produtos;


-- 2.4 - Quantidade de pedidos por cliente
SELECT
    Clientes.Nome AS Cliente,
    COUNT(Pedidos.IDPedido) AS TotalPedidos
FROM Clientes
LEFT JOIN Pedidos
    ON Clientes.IDCliente = Pedidos.IDCliente
GROUP BY Clientes.Nome;


-- ============================================================
-- 03. GROUP BY E HAVING
-- ============================================================

-- 3.1 - Clientes com mais de um item nos pedidos
SELECT
    Clientes.Nome AS Cliente,
    SUM(ItensPedido.Quantidade) AS TotalItens
FROM Clientes
INNER JOIN Pedidos
    ON Clientes.IDCliente = Pedidos.IDCliente
INNER JOIN ItensPedido
    ON Pedidos.IDPedido = ItensPedido.IDPedido
GROUP BY Clientes.Nome
HAVING SUM(ItensPedido.Quantidade) > 1;


-- 3.2 - Produtos com quantidade total vendida superior a uma unidade
SELECT
    Produtos.NomeProduto,
    SUM(ItensPedido.Quantidade) AS QuantidadeVendida
FROM Produtos
INNER JOIN ItensPedido
    ON Produtos.IDProduto = ItensPedido.IDProduto
GROUP BY Produtos.NomeProduto
HAVING SUM(ItensPedido.Quantidade) > 1;


-- ============================================================
-- 04. SUBCONSULTAS COM IN E NOT IN
-- ============================================================

-- 4.1 - Clientes que possuem pedidos
SELECT
    Nome
FROM Clientes
WHERE IDCliente IN (
    SELECT IDCliente
    FROM Pedidos
);


-- 4.2 - Clientes que não possuem pedidos
SELECT
    Nome
FROM Clientes
WHERE IDCliente NOT IN (
    SELECT IDCliente
    FROM Pedidos
);


-- ============================================================
-- 05. EXISTS E NOT EXISTS
-- ============================================================

-- 5.1 - Clientes que possuem pedidos com itens
SELECT
    Clientes.Nome
FROM Clientes
WHERE EXISTS (
    SELECT 1
    FROM Pedidos
    INNER JOIN ItensPedido
        ON Pedidos.IDPedido = ItensPedido.IDPedido
    WHERE Pedidos.IDCliente = Clientes.IDCliente
);


-- 5.2 - Clientes que possuem pedidos sem itens
SELECT
    Clientes.Nome
FROM Clientes
WHERE EXISTS (
    SELECT 1
    FROM Pedidos
    WHERE Pedidos.IDCliente = Clientes.IDCliente
      AND NOT EXISTS (
          SELECT 1
          FROM ItensPedido
          WHERE ItensPedido.IDPedido = Pedidos.IDPedido
      )
);


-- 5.3 - Clientes que ainda não possuem compras concluídas
SELECT
    Clientes.Nome
FROM Clientes
WHERE NOT EXISTS (
    SELECT 1
    FROM Pedidos
    WHERE Pedidos.IDCliente = Clientes.IDCliente
      AND Pedidos.StatusPedido = 'Concluído'
);


-- ============================================================
-- 06. CONSULTAS POR CATEGORIA
-- ============================================================

-- 6.1 - Resumo de produtos por categoria
SELECT
    Categorias.NomeCategoria,
    COUNT(DISTINCT Produtos.IDProduto) AS TotalProdutos,
    COALESCE(SUM(Produtos.EstoqueAtual), 0) AS EstoqueTotal
FROM Categorias
LEFT JOIN Produtos
    ON Categorias.IDCategoria = Produtos.IDCategoria
GROUP BY Categorias.NomeCategoria;


-- ============================================================
-- 07. CONSULTAS POR STATUS
-- ============================================================

-- 7.1 - Quantidade de pedidos por status
SELECT
    StatusPedido,
    COUNT(*) AS TotalPedidos
FROM Pedidos
GROUP BY StatusPedido;


-- 7.2 - Quantidade de pedidos por status de pagamento
SELECT
    StatusPagamento,
    COUNT(*) AS TotalPedidos
FROM Pedidos
GROUP BY StatusPagamento;


-- ============================================================
-- 08. CONSULTAS POR PERÍODO
-- ============================================================

-- 8.1 - Quantidade de pedidos e valor total por dia
SELECT
    CAST(Pedidos.DataPedido AS DATE) AS DataPedido,
    COUNT(DISTINCT Pedidos.IDPedido) AS TotalPedidos,
    SUM(
        ItensPedido.Quantidade * ItensPedido.PrecoUnitario
    ) AS ValorTotal
FROM Pedidos
INNER JOIN ItensPedido
    ON Pedidos.IDPedido = ItensPedido.IDPedido
GROUP BY CAST(Pedidos.DataPedido AS DATE)
ORDER BY DataPedido;


-- 8.2 - Pedidos de um cliente em determinado período
-- Altere as datas conforme necessário.
SELECT
    IDPedido,
    IDCliente,
    DataPedido,
    StatusPedido
FROM Pedidos
WHERE IDCliente = 1
  AND DataPedido >= '2026-01-01'
  AND DataPedido < '2027-01-01'
ORDER BY DataPedido;


-- ============================================================
-- 09. RELATÓRIOS E VALIDAÇÕES ADICIONAIS
-- ============================================================

-- 9.1 - Produtos mais pedidos
SELECT
    Produtos.NomeProduto,
    SUM(ItensPedido.Quantidade) AS QuantidadeVendida
FROM Produtos
INNER JOIN ItensPedido
    ON Produtos.IDProduto = ItensPedido.IDProduto
GROUP BY Produtos.NomeProduto
ORDER BY QuantidadeVendida DESC;


-- 9.2 - Relatório geral por cliente
SELECT
    Clientes.Nome AS Cliente,
    COUNT(DISTINCT Pedidos.IDPedido) AS TotalPedidos,
    COALESCE(SUM(ItensPedido.Quantidade), 0) AS TotalItens,
    COALESCE(
        SUM(ItensPedido.Quantidade * ItensPedido.PrecoUnitario),
        0
    ) AS ValorTotal
FROM Clientes
LEFT JOIN Pedidos
    ON Clientes.IDCliente = Pedidos.IDCliente
LEFT JOIN ItensPedido
    ON Pedidos.IDPedido = ItensPedido.IDPedido
GROUP BY Clientes.Nome;


-- 9.3 - Resumo financeiro e de itens por pedido
SELECT
    Pedidos.IDPedido,
    Clientes.Nome AS Cliente,
    Pedidos.StatusPedido,
    COUNT(ItensPedido.IDItemPedido) AS TotalItens,
    COALESCE(
        SUM(ItensPedido.Quantidade * ItensPedido.PrecoUnitario),
        0
    ) AS ValorTotal
FROM Pedidos
INNER JOIN Clientes
    ON Pedidos.IDCliente = Clientes.IDCliente
LEFT JOIN ItensPedido
    ON Pedidos.IDPedido = ItensPedido.IDPedido
GROUP BY
    Pedidos.IDPedido,
    Clientes.Nome,
    Pedidos.StatusPedido
ORDER BY Pedidos.IDPedido;


-- 9.4 - Verificar produtos com preço ou estoque negativos
SELECT
    IDProduto,
    NomeProduto,
    PrecoAtual,
    EstoqueAtual
FROM Produtos
WHERE PrecoAtual < 0
   OR EstoqueAtual < 0;


-- ============================================================
-- FIM DO ARQUIVO DE CONSULTAS
-- ============================================================
