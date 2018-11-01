

-- ================================================

-- Template generated from Template Explorer using:

-- Create Procedure (New Menu).SQL

--

-- Use the Specify Values for Template Parameters 

-- command (Ctrl-Shift-M) to fill in the parameter 

-- values below.

--

-- This block of comments will not be included in

-- the definition of the procedure.

-- ================================================

SET ANSI_NULLS ON

GO

SET QUOTED_IDENTIFIER ON

GO

-- =============================================

-- Author:		MaximIvashkov

-- Create date:     2018-11-01

-- Description:	Compute week categories for forecasting applications

-- =============================================

CREATE PROCEDURE CORE_WEEK_CATEGORIES 

	-- Period to update

	@beginDate date = '2015-01-01', 

	@endDate date = '2018-01-01'

AS

BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from

	-- interfering with SELECT statements.

	SET NOCOUNT ON;




    /****** Script for SelectTopNRows command from SSMS  ******/




     

   update [CORE_WEEK]

   set Category =  DATEPART(QUARTER, Datemin)

   where DateMin between @beginDate and @endDate




  ------------------------------------------------------------------------------------

  -- Summer vacations category

  ;with ZV as (

  -- set   all

  select min([Start Date]) [Start Date] , max([End Date]) [End Date] 

  from [dbo].[CORE_CALENDAR]

  where lower([Subject]) like '%zomer%' and [Start Date] between @beginDate and @endDate

  group by year([Start Date])

  )

  update W

  set Category = case when ZV.[Start Date] is not null then 'ZV' END   

  from  [CORE_WEEK] W 

  inner join ZV on W.[DateMin]<=[End Date] and [DateMax]>=ZV.[Start Date] 




  ;with ZV as (

  -- set   begin

  select min([Start Date]) [Start Date] 

  from [dbo].[CORE_CALENDAR]

  where lower([Subject]) like '%zomer%' and [Start Date] between @beginDate and @endDate

  group by year([Start Date])

  )




  update W

  set Category = case when ZV.[Start Date] is not null then 'ZVB' END   

  from  [CORE_WEEK] W inner join ZV on ZV.[Start Date] between [DateMin] and [DateMax]




  ;with ZV as (

  -- set   eind

  select max([End Date]) [End Date] from [dbo].[CORE_CALENDAR]

  where lower([Subject]) like '%zomer%' and [End Date] between @beginDate and @endDate

  group by year([End Date])

  )

  update W

  set Category = case when ZV.[End Date] is not null then 'ZVE' END   

  from  [CORE_WEEK] W inner join ZV on ZV.[End Date] between [DateMin] and [DateMax]




  ------------------------------------------------------------------------------------

  -- Voorjaarsvakantie (spring vacations)

  -----------------------------------------------------------------------------------

  ;with ZV as (

  -- set   all

  select min([Start Date]) [Start Date] , max([End Date]) [End Date] from [dbo].[CORE_CALENDAR]

  where lower([Subject]) like '%voorjaarsvakantie%'

  and [Start Date] between @beginDate and @endDate

  group by year([Start Date])

  )

  update W

  set Category = case when ZV.[Start Date] is not null then 'VV' END   

  from  [CORE_WEEK] W 

  inner join ZV on W.[DateMin]<=[End Date] and [DateMax]>=ZV.[Start Date]   




  ;with ZV as (

  -- set   begin

  select min([Start Date]) [Start Date] from [dbo].[CORE_CALENDAR]

   where lower([Subject]) like '%voorjaarsvakantie%'

   and [Start Date] between @beginDate and @endDate

  group by year([Start Date])

  )

  update W

  set Category = case when ZV.[Start Date] is not null then 'VVB' END   

  from  [CORE_WEEK] W 

  inner join ZV on ZV.[Start Date] between [DateMin] and [DateMax]




  ; with ZV as (

  -- set   eind

  select max([End Date]) [End Date] from [dbo].[CORE_CALENDAR]

  where lower([Subject]) like '%voorjaarsvakantie%'

  and [End Date] between @beginDate and @endDate

  group by year([End Date])

  )




  update W

  set Category = case when ZV.[End Date] is not null then 'VVE' END   

  from  [CORE_WEEK] W inner join ZV on ZV.[End Date] between [DateMin] and [DateMax]

  ------------------------------------------------------------------------------------ 




  ------------------------------------------------------------------------------------

  -- Herfstvakantie (herfts vacations)

  -----------------------------------------------------------------------------------

  ;with ZV as (

  -- set   all

  select min([Start Date]) [Start Date] , max([End Date]) [End Date] 

  from [dbo].[CORE_CALENDAR]

  where lower([Subject]) like '%herfstvakantie%'

  and [Start Date] between @beginDate and @endDate

  group by year([Start Date])

  )




  update W

  set Category = case when ZV.[Start Date] is not null then 'HV' END   

  from  [CORE_WEEK] W inner join ZV on W.[DateMin]<=[End Date] and [DateMax]>=ZV.[Start Date]   




  ;with ZV as (

  -- set begin

  select min([Start Date]) [Start Date] from [dbo].[CORE_CALENDAR]

  where lower([Subject]) like '%herfstvakantie%'

  and [Start Date] between @beginDate and @endDate

  group by year([Start Date])

  )

  update W

  set Category = case when ZV.[Start Date] is not null then 'HVB' END   

  from  [CORE_WEEK] W inner join ZV on ZV.[Start Date] between [DateMin] and [DateMax]




  ; with ZV as (

  -- set   eind

  select max([End Date]) [End Date] from [dbo].[CORE_CALENDAR]

  where lower([Subject]) like '%herfstvakantie%'

  and [End Date] between @beginDate and @endDate

  group by year([End Date])

  )

  update W

  set Category = case when ZV.[End Date] is not null then 'HVE' END   

  from  [CORE_WEEK] W inner join ZV on ZV.[End Date] between [DateMin] and [DateMax]

  ------------------------------------------------------------------------------------ 




  ------------------------------------------------------------------------------------

  -- Meivakantie  

  -----------------------------------------------------------------------------------

  ;with ZV as (

  -- set Meivakantie all

  select min([Start Date]) [Start Date] , max([End Date]) [End Date] 

  from [dbo].[CORE_CALENDAR]

  where LOWER([Subject]) like '%meivakantie%'

  and [Start Date] between @beginDate and @endDate

  group by year([Start Date])

  )

  update W

  set Category = case when ZV.[Start Date] is not null then 'MV' END   

  from  [CORE_WEEK] W 

  inner join ZV on W.[DateMin]<=[End Date] and [DateMax]>=ZV.[Start Date]   

   

  ------------------------------------------------------------------------------------

  -- Christmasday  

  -----------------------------------------------------------------------------------

  ;with ZV as (

  -- set kerstdag all

  select min([Start Date]) [Start Date] , max([End Date]) [End Date] from [dbo].[CORE_CALENDAR]

  where LOWER([Subject]) like '%kerstdag%'

  and [Start Date] between @beginDate and @endDate

  group by year([Start Date])

  )

  update W

  set Category = case when ZV.[Start Date] is not null then 'K' END   

  from  [CORE_WEEK] W inner join ZV on W.[DateMin]<=[End Date] and [DateMax]>=ZV.[Start Date]   

   

  

  ------------------------------------------------------------------------------------

  --  Eester

  -----------------------------------------------------------------------------------

  ;with ZV as (

  -- set kerstdag all

  select min([Start Date]) [Start Date] , max([End Date]) [End Date] from [dbo].[CORE_CALENDAR]

  where LOWER([Subject]) like '%paasdag%'

  and [Start Date] between @beginDate and @endDate

  group by year([Start Date])

  )

  update W

  set Category = case when ZV.[Start Date] is not null then 'PA' END   

  from  [CORE_WEEK] W inner join ZV on W.[DateMin]<=[End Date] and [DateMax]>=ZV.[Start Date]   




  ------------------------------------------------------------------------------------

  --  hemelvaart  

  -----------------------------------------------------------------------------------

  ;with ZV as (

  -- set kerstdag all

  select min([Start Date]) [Start Date] , max([End Date]) [End Date] from [dbo].[CORE_CALENDAR]

  where LOWER([Subject]) like '%hemelvaart%'

  and [Start Date] between @beginDate and @endDate

  group by year([Start Date])

  )

  update W

  set Category = case when ZV.[Start Date] is not null then 'HE' END   

  from  [CORE_WEEK] W inner join ZV on W.[DateMin]<=[End Date] and [DateMax]>=ZV.[Start Date]   

   

  ------------------------------------------------------------------------------------ 




  ------------------------------------------------------------------------------------

  --  pinksterdag  

  -----------------------------------------------------------------------------------

  ;with ZV as (

  -- set kerstdag all

  select min([Start Date]) [Start Date] , max([End Date]) [End Date] from [dbo].[CORE_CALENDAR]

  where LOWER([Subject]) like '%pinkster%'

  and [Start Date] between @beginDate and @endDate

  group by year([Start Date])

  )

  update W

  set Category = case when ZV.[Start Date] is not null then 'PI' END   

  from  [CORE_WEEK] W inner join ZV on W.[DateMin]<=[End Date] and [DateMax]>=ZV.[Start Date]   

   

  ------------------------------------------------------------------------------------ 

   /****** TESTEN  ******/




   /*

  SELECT TOP 1000  *

  FROM [dbo].[CORE_WEEK]

  where isoyear in (2019,2018,2017)

  order by WeekKey




  select * FROM [dbo].[CORE_CALENDAR] 

  where [Start Date] between '2016-01-01' and '2018-12-31'




  -- naive forecast 

  -- data per day group per week

-- forecast week 20 2018

 select ISOYearAndWeekNumber, ISOWeekNumberOfYear, Category, IsoYear 

 from [dbo].[CORE_WEEK]

 where ISOYearAndWeekNumber='2018W20'

 */




END

GO


