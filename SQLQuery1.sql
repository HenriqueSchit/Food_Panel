
CREATE VIEW T1 as (SELECT * FROM [Tabela 1 - Energia, macronutrientes e fibra na composição de alimentos por 100 gramas de parte comestível V2])
CREATE VIEW T2 as (SELECT * FROM [Tabela 2 - Gorduras e açúcar na composição de alimentos por 100 gramas de parte comestível V2])
CREATE VIEW T3 as (SELECT * FROM [Tabela 3 - Minerais na composição de alimentos por 100 gramas de parte comestível V2])
CREATE VIEW T4 as (SELECT * FROM [Tabela 4 - Vitaminas na composição de alimentos por 100 gramas de parte comestível V2])

-- Quais alimentos com maior densidade calórica (com exceção de óleos)? E quais são mais pobres (com exceção de bebidas)?

SELECT top 10 T1.Descricao_do_alimento, T1.Tipo, (T1.Energia_kcal/100) AS Caloria FROM T1
WHERE Tipo NOT LIKE '%oleo%'
ORDER BY Caloria desc

SELECT top 10 T1.Descricao_do_alimento, T1.Tipo, (T1.Energia_kcal/100) AS Caloria FROM T1
WHERE Tipo NOT LIKE '%Bebidas%'
ORDER BY Caloria

-- Quais são as principais fontes de fibras na dieta brasileira?

SELECT top 10 T1.Descricao_do_alimento, T1.Tipo, (T1.Fibra_alimentar_total_g/100) AS Fibra_Alimentar FROM T1
ORDER BY Fibra_Alimentar desc

-- Quais alimentos são as principais fontes de gorduras saturadas na dieta?

SELECT top 10 T2.Descricao_do_alimento, T2.Tipo, (T2.AG_Saturados_g/100) AS G_Saturadas FROM T2
ORDER BY G_Saturadas desc

-- Quais alimentos mais proteicos de origem vegetal possuem equivalência em relação proteica a alimentos de origem animal?

WITH VegetalxAnimal AS (
  SELECT V.Codigo_do_alimento AS V_codigo, V.Descricao_do_alimento AS V_desc, V.Proteina_g AS V_prot, V.Codigo_da_preparacao AS V_codprep,
  A.Codigo_do_alimento AS A_codigo, A.Descricao_do_alimento AS A_desc, A.Proteina_g AS A_prot, A.Codigo_da_preparacao AS A_codprep,
    ABS(A.Proteina_g - V.Proteina_g) AS Diferenca_Proteina,
    ROW_NUMBER() OVER(PARTITION BY V.Codigo_do_alimento ORDER BY ABS(V.Proteina_g - A.Proteina_g) ASC) AS RowNum
  FROM T1 AS V
  INNER JOIN T1 AS A ON V.Tipo IN ('Cereais e leguminosas', 'Hortalicas tuberosas', 'Farinhas. feculas e massas', 'Cocos. castanhas e nozes',
									'Hortalicas folhosas. frutosas e outras', 'Frutas', 'Sais e condimentos') 
             AND A.Tipo IN ('Aves e Ovos', 'Carnes e visceras', 'Carnes Industrializadas', 'Pescados e frutos do mar', 'Laticinios'))
SELECT TOP 10 V_desc, (V_prot/100) AS "Proteína vegetal", A_desc, (A_prot/100) AS "Proteína Animal", Diferenca_Proteina/100
FROM VegetalxAnimal
WHERE RowNum = 1 AND A_codprep = 99 AND V_desc NOT LIKE 'Coentro'
ORDER BY V_prot desc

-- Em uma dieta restritiva em calorias, quais as bebidas com menor dano?

SELECT top 10 T1.Descricao_do_alimento, T1.Tipo, (T1.Energia_kcal/100) AS Caloria FROM T1
WHERE Tipo LIKE '%Bebidas%'
ORDER BY Caloria

SELECT top 10 T1.Descricao_do_alimento, T1.Tipo, (T1.Energia_kcal/100) AS Caloria FROM T1
WHERE Tipo LIKE '%Bebidas alcoolica%'
ORDER BY Caloria

-- Em uma dieta restritiva em calorias, quais alimentos possuem uma maior proporção de proteína comparado a carboidrato?

WITH DietaRest AS 
(SELECT T1.Codigo_do_alimento AS T1_cod, T1.Descricao_do_alimento AS T1_desc, T1.Tipo AS T1_tipo, T1.Proteina_g AS T1_prot, 
		T2.AG_Saturados_g AS T2_satur,
    ROW_NUMBER() OVER(PARTITION BY T1.Codigo_do_alimento ORDER BY T1.Proteina_g - T2.AG_Saturados_g DESC) AS RowNum
  FROM T1 INNER JOIN T2 ON T1.Codigo_do_alimento = T2.Codigo_do_alimento
  WHERE T1.Tipo NOT LIKE 'Sais e condimentos')
SELECT top 10 T1_desc AS "Alimento", T1_tipo AS "Tipo", (T1_prot/100) AS "Proteína", 
				(T2_satur/100) AS G_Saturada, (T1_prot/NULLIF(T2_satur,0)) AS "Prop Proteina x G Saturada"
FROM DietaRest
WHERE RowNum = 1 AND T1_prot IS NOT NULL AND T2_satur IS NOT NULL
ORDER BY "Prop Proteina x G Saturada" desc

-- A única maneira de obter vitamina D é por meio do sol? Quais alimentos contribuem para a absorção dessa vitamina?

WITH VitamD AS 
(SELECT T4.Descricao_do_alimento, T4.Tipo, T4.Vitamina_D_mcg,
	ROW_NUMBER() OVER(PARTITION BY T4.Descricao_do_alimento ORDER BY T4.Vitamina_D_mcg DESC) AS RowNum
	FROM T4)
SELECT top 10 Descricao_do_alimento, Tipo, (Vitamina_D_mcg/100) AS "Vitamina D (mcg)"
FROM VitamD
WHERE RowNum = 1
ORDER BY "Vitamina D (mcg)" desc


-- A única maneira de fortalecer os ossos é por meio do consumo de laticínios? Quais os principais alimentos que auxiliam na absorção do cálcio? 

SELECT top 10 T3.Descricao_do_alimento, T3.Tipo, T3.Descricao_da_preparacao, (T3.Calcio_mg/100) AS "Calcio (mg)" FROM T3
WHERE Tipo != 'Laticinios'
ORDER BY "Calcio (mg)" desc




WITH VegetalxAnimal AS (
  SELECT V.Codigo_do_alimento AS V_codigo, V.Descricao_do_alimento AS V_desc, V.Proteina_g AS V_prot, V.Codigo_da_preparacao AS V_codprep,
  A.Codigo_do_alimento AS A_codigo, A.Descricao_do_alimento AS A_desc, A.Proteina_g AS A_prot, A.Codigo_da_preparacao AS A_codprep,
    ABS(A.Proteina_g - V.Proteina_g) AS Diferenca_Proteina,
    ROW_NUMBER() OVER(PARTITION BY V.Codigo_do_alimento ORDER BY ABS(V.Proteina_g - A.Proteina_g) ASC) AS RowNum
  FROM T5 AS V
  INNER JOIN T5 AS A ON V.Tipo IN ('Cereais e leguminosas', 'Hortalicas tuberosas', 'Farinhas. feculas e massas', 'Cocos. castanhas e nozes',
									'Hortalicas folhosas. frutosas e outras', 'Frutas', 'Sais e condimentos') 
             AND A.Tipo IN ('Aves e Ovos', 'Carnes e visceras', 'Carnes Industrializadas', 'Pescados e frutos do mar', 'Laticinios'))
SELECT TOP 10 V_desc, (V_prot/100) AS "Proteína vegetal", A_desc, (A_prot/100) AS "Proteína Animal", Diferenca_Proteina/100
FROM VegetalxAnimal
WHERE RowNum = 1 AND A_codprep = 99
ORDER BY V_prot desc



