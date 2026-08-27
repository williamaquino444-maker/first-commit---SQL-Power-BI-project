-- SABER LA MAGNITUD DE DATOS A ANALIZAR

SELECT count(*) 
FROM `portfolioproyect-505419.newportfolio.proyect`;
--

--REVISAR EL OBJETIVO QUE ES EL ESTADO DE LOS PRESTAMOS, Y CUANTAS "CATEGORIAS PRESENTA LA DATA"
SELECT loan_status, count(loan_status) AS loan_category
FROM `portfolioproyect-505419.newportfolio.proyect`
GROUP BY loan_status
ORDER BY loan_category desc;
--

-- IDENTIFICAR NULOS EN VARIABLE QUE USAREMOS PARA EL ANALISIS
SELECT countif(annual_inc is null) AS annual_inc_nulls,
       countif(int_rate is null) AS int_rate_nulls,
       countif(emp_length is null) AS emp_lenght_nulls
FROM `portfolioproyect-505419.newportfolio.proyect`;
--

--REVISAR EL PERFIL DEL CLIENTE POR RIESGO
--RELACION ESTADO DEL PRESTAMO VS TASA 
--COMPORTAMIENTO DEL INGRESO ANUL RELACIONADO CON EL ESTADO DEL PRESTAMO
SELECT loan_status, 
       ROUND(avg(annual_inc),2) AS Aveg_anual_income,
       ROUND(avg(int_rate),2) AS Aveg_int_rate
FROM `portfolioproyect-505419.newportfolio.proyect`
GROUP BY loan_status
ORDER BY Aveg_int_rate desc;
--

--ANALISIS POR PLAZO DE PRESTAMO
--SABER LA CANTIDAD DE PRESTAMOS A PLAZOS NO DA UNA DE IDEA DEL MODELO DE NEGOCIO Y SE VE QUE LAS PERSONAS PREFIEREN PRESTAMOS A 36 MESES Y TAMBIEN DE LAS CANTIDADES PROMEDIO ENTREGADAD DEPENDIENDO DE LOS PLAZOS 13.013.90 ES EL AVG ENTREGADO A PERSONAS QUE PIDEN PRESTAMOS A 36 MESES 

SELECT term,
       count(*) AS total_loan,
       ROUND(avg(loan_amnt),2) as aveg_loan_amount,
       ROUND(avg(int_rate),2) as aveg_int_rate
FROM `portfolioproyect-505419.newportfolio.proyect`
GROUP BY term;
--

--CRUCE ENTRE EL PLAZO Y EL RIESGO(LOAN_STATUS) ESTO ES PARA SABER LA CANTIDAD DE PRESTAMOS QUE ESTAN EN MORA Y EN LOS PLAZOS QUE SE DIERON ESTE ESTADO  36 months	Late (31-120 days)	70 ES DONDE SE PRESENTA LO MAS CRITICO EN COMPARACION CON  60 months	Late (31-120 days)	16 QUE SE PODRIA SUPONER QUE HABRIA MAS MOROSIDAD POR LA CANTIDAD DE PLAZOS
SELECT  
       term,
       loan_status,
       count(*) AS count_total
 FROM `portfolioproyect-505419.newportfolio.proyect`
GROUP BY term, loan_status
ORDER BY count_total desc;
--

--AQUI BUSCAMOS EL GRADO DENOMINADO POR LA EMPRESA Y SABER MONTO PROMEDIO PRESTADO, INTERES PROMEDIO Y PROMEDIO DE INGRESOS, LOS QUE TIENEN MAYORES INGRESO TIENE MEJOR TASA DE PRESTAMO.
SELECT grade,
       ROUND(avg(loan_amnt),2) as aveg_loan_amount,
       ROUND(avg(int_rate),2) as aveg_int_rate,
       ROUND(avg(annual_inc),2) as aveg_income_amount
FROM `portfolioproyect-505419.newportfolio.proyect`
GROUP BY  grade
ORDER BY grade; 
--

--DECIDIMOS VER LA CANTIDAD DE PRESTAMOS A CLIENTES DE ALTO RIESGO Y BAJOS INGRESOS.
SELECT grade,
       count(*) AS loan_total,
       ROUND(avg(loan_amnt),2) as aveg_loan_amount
FROM `portfolioproyect-505419.newportfolio.proyect`
WHERE grade IN ('E','F','G') and annual_inc < 50000
GROUP BY grade
ORDER BY grade;
--

--AQUI BUSCAMOS SABER EL PATRON DE LA CARTERA Y SE PUEDE VER QUE SE LE ENTREGA CREDITOS A PERSONAS QUE TENGAS MAS DE 10 AÑOS DE ANTIGUEDAD LABORAL Y TAMBIEN CON UN INGRESO ALTO
SELECT emp_length,
       count(*) AS total_loan,
       ROUND(avg(loan_amnt),2) as aveg_loan_amount,
       ROUND(avg(annual_inc),2) as aveg_income_amount
FROM `portfolioproyect-505419.newportfolio.proyect`
GROUP BY emp_length
ORDER BY total_loan desc;
--

--BUSCAMOS REVISAR EL DTI RATIO DEUDA-INGRESO QUE TAN COMPROMETIDO ESTA SU SUELDO CON LA DEUDA.
SELECT emp_length,
       ROUND(avg(dti),2) AS average_debt_to_income
FROM `portfolioproyect-505419.newportfolio.proyect`
GROUP BY  emp_length
ORDER BY average_debt_to_income  desc;
--

--ESTAMOS BUSCANDO EL PROPOSITO DE LOS PRESTAMOS Y EL TOTAL INVERTIDO EN CADA CATEGORIA DE PROPOSITO DE PRESTAMO
SELECT purpose,
       count(*) AS total_loan,
       ROUND(sum(loan_amnt),2) as sum_loan_amount,
       ROUND(avg(int_rate),2) as aveg_interest_amount
FROM `portfolioproyect-505419.newportfolio.proyect`
GROUP BY purpose
ORDER BY total_loan desc;
--
--AQUI LO MISMO QUE LA ANTERIOR PERO BUSCAMOS SABER EL PROPOSITO VS INTERESES MAS ALTOS.
SELECT purpose,
       count(*) AS total_loan,
       ROUND(sum(loan_amnt),2) as sum_loan_amount,
       ROUND(avg(int_rate),2) as aveg_interest_amount
FROM `portfolioproyect-505419.newportfolio.proyect`
GROUP BY purpose
ORDER BY aveg_interest_amount desc;
--

--DESPUES DE TODO REVISAMOS LOS DUPLICADOS Y COMO NO TENEMOS ID ENTONCES VAMOS A TENER QUE ELIMINAR COLUMNAS REPETIDAS TOMANDO COINCIDENCIAS EN 4 COLUMNAS PARA QUE NO ALTERE EL ANALISIS FINAL.
SELECT COUNT(*) AS REPETIDAS,
       loan_amnt,
       annual_inc,
       int_rate,
       issue_d
FROM `portfolioproyect-505419.newportfolio.proyect`
GROUP BY  loan_amnt,
          annual_inc,
          int_rate,
          issue_d
HAVING COUNT(*) > 1;
--

--limpieza de datos duplicados y como nos dimos cuenta que de aqui ya pasamos a representar datos nos toca seleccionar las columnas necesarias para nuestro analisis, y como powerbi funciona por dimensiones tenemos que pensar que dimensiones nos podria funcionar en temas metricos, categorias, tiempo y geografia.

WITH TABLA AS (
  SELECT *,
       row_number() over(PARTITION BY
       CAST(loan_amnt AS STRING),
       CAST(annual_inc AS STRING),
       CAST(int_rate AS STRING),
       issue_d 
       order by loan_amnt
       )
       
       AS numeracion
FROM `portfolioproyect-505419.newportfolio.proyect`
)

SELECT--METRICAS FINANCIERAS
       loan_amnt,
       funded_amnt,
       funded_amnt_inv,
       int_rate,
       installment,
       annual_inc,
       dti,
       --ESTADO DEL CREDITO
       loan_status,
       grade,
       sub_grade,
       term,
       --DATOS DEMOGRAFICOS
       home_ownership,
       verification_status,
       purpose,
       addr_state,
       emp_length,
       --FECHAS
       issue_d,
       last_pymnt_d
FROM TABLA
WHERE numeracion = 1;
