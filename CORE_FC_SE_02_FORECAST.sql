/****** Object:  StoredProcedure [dbo].[SP_PLANSIS_FORECAST_NSE_MBA]    Script Date: 10-12-2018 14:51:47 ******/
SET ANSI_NULLS r
GO
SET QUOTED_IDENTIFIER ON
GO

 -- historical data per week
 -- parameter 6 where
  CREATE PROCEDURE [dbo].[CORE_FC_SE_02_FORECAST]
	-- Add the parameters for the stored procedure here
	 @ActivityId int = 0 
	,@ActivitySourceId int=@ActivityId
	,@ForecastId int= 0
	,@ForecastSourceId int= 1
	,@WEEK_FROM NVARCHAR(7)='2019W01'
	,@WEEK_TO NVARCHAR(7)='2019W52'
	,@EXTRA_PCT float=1.0

AS
BEGIN

 DELETE W
		  from [dbo].[PLANSIS_FC_WORK_DAY] W 
		  inner join [dbo].[dim_date] D on W.Date=D.FullDate
		  where W.ActivityId = @ActivityId AND W.ForecastId=@ForecastId and D.ISOYearAndWeekNumber between @WEEK_FROM and @WEEK_TO;
  
  
  -- History per day
  with HD as (
  select D.ISOYearAndWeekNumber, D.ISOYearAndWeekInteger, D.IsoYear,D.ISOWeekNumberOfYear,W.Category, D.DayNumberOfWeek, Value1 
  from [dbo].[PLANSIS_FC_WORK_DAY] V
  inner join [dbo].[dim_date] D on V.Date=D.FullDate
  inner join [dbo].[CORE_WEEK] W on W.ISOYearAndWeekNumber=D.ISOYearAndWeekNumber
  where activityid=@ActivitySourceId and Forecastid=@ForecastSourceId and D.ISOYearAndWeekNumber < @WEEK_FROM  
  )

  , HW as (
  select ISOYearAndWeekNumber, ISOYearAndWeekInteger, isnull(sum(Value1),0) as Value1 
  from HD
  group by ISOYearAndWeekNumber,ISOYearAndWeekInteger
  )

  , W as ( -- select proper weeks based on the category rule and weeknumber nearness
 select W.ISOYearAndWeekNumber, W.ISOWeekNumberOfYear, W.Category, W.IsoYear 
 , (select top 1 ISOYearAndWeekNumber from [dbo].[CORE_WEEK] where IsoYear=W.IsoYear-1 and Category=W.Category
    order by ABS(convert(int, W.ISOWeekNumberOfYear)-convert(int,ISOWeekNumberOfYear))) Y1
 , (select top 1 ISOYearAndWeekNumber from [dbo].[CORE_WEEK] where IsoYear=W.IsoYear-2 and Category=W.Category
    order by ABS(convert(int, W.ISOWeekNumberOfYear)-convert(int,ISOWeekNumberOfYear))) Y2
 , (select top 1 ISOYearAndWeekNumber from [dbo].[CORE_WEEK] where IsoYear=W.IsoYear-3 and Category=W.Category
    order by ABS(convert(int, W.ISOWeekNumberOfYear)-convert(int,ISOWeekNumberOfYear))) Y3
 from [dbo].[CORE_WEEK] W
 where ISOYearAndWeekNumber between @WEEK_FROM and @WEEK_TO) --= '2018W20'

  -- weeks with trend measurement
  -- weeks with trend measurement
 ,WT0 as (
 -- join selected weeks and get historical data per week
 select W.ISOYearAndWeekNumber, W.Category, W.IsoYear
 , isnull(W.Y1, 0) as Y1, isnull(W.Y2,0) as Y2,isnull(W.Y3,0) as Y3
 , isnull(HW3.Value1,0) as VY3  , isnull(HW2.Value1,0) as VY2 , isnull(HW1.Value1,0) as VY1
 , isnull(HW3.Value1,isnull(HW2.Value1,isnull(HW1.Value1,0))) as VEY3  , isnull(HW2.Value1,isnull(HW1.Value1,0)) as VEY2 , isnull(HW1.Value1,0) as VEY1

 from W
 left join HW HW1 on W.Y1=HW1.ISOYearAndWeekNumber  
 left join HW HW2 on W.Y2=HW2.ISOYearAndWeekNumber  
 left join HW HW3 on W.Y3=HW3.ISOYearAndWeekNumber  
 )
 ,WT1 as (
 select *
 , case when VEY1 >=VEY2 and VEY2 >=VEY3 THEN 'TRENDUP'
    WHEN (VEY1<=VEY2 and VEY2<=VEY3) THEN 'TRENDDOWN' 
    ELSE 'NO TREND'  END
    as Trend
     from WT0)
 -- WEEK FORECAST
 ,WT as (
 -- join selected weeks and get historical data per week
 select ISOYearAndWeekNumber,Category, IsoYear
 ,Y1,Y2,Y3
 , VY3  -- use most recent year if we do not have y-1 data
  , VY2   
  , VY1
 , case when Trend<>'NO TREND' then  (VEY1*0.7+VEY2*0.3) *(1+0.6*(1.3*(VEY1-VEY2)/VY2+(VEY2-VEY3)/1.3/VEY3 )/2) -- 0.6 is trend power coefficient to reduce possible trends if found.
    ELSE (0.5*VEY1+0.25*VEY2+ 0.25*VEY3)  END
    as Y0
,  Trend
 from WT1)

 -- FORECAST WEEK TO DAY WITH DAYOFTHEWEEK WEIGHT
 , DOWDS as(
    select D.FullDate, D.ISOYearAndWeekNumber, WT.Y0, 
    case when (isnull(WT.VY1,0)+isnull(WT.VY2,0)+isnull(WT.VY3,0))>0 then 
    1.0*(isnull(HW1.Value1,0)+isnull(HW2.Value1,0)+isnull(HW3.Value1,0))/(isnull(WT.VY1,0)+isnull(WT.VY2,0)+isnull(WT.VY3,0))
    else 0 end PCT
  , isnull(HW1.Value1,0) as HW1, isnull(HW2.Value1,0) as HW2,isnull(HW3.Value1,0) as HW3,WT.VY1,WT.VY2,WT.VY3
  ,WT.Category,Trend, D.DayNumberOfWeek
  from WT  
  inner join [dbo].[dim_date] D on WT.ISOYearAndWeekNumber=D.ISOYearAndWeekNumber
    left join HD HW1 on WT.Y1=HW1.ISOYearAndWeekNumber  and HW1.DayNumberOfWeek=D.DayNumberOfWeek
    left join HD HW2 on WT.Y2=HW2.ISOYearAndWeekNumber  and HW2.DayNumberOfWeek=D.DayNumberOfWeek
    left join HD HW3 on WT.Y3=HW3.ISOYearAndWeekNumber  and HW3.DayNumberOfWeek=D.DayNumberOfWeek
)

INSERT INTO  [dbo].[PLANSIS_FC_WORK_DAY] ([Date],[ActivityId],[ForecastId],[Value1],[Value2],[Value3],[Value4],Value5,Value6) 
SELECT FullDate, @ActivityId, @ForecastId, 1.0*Y0*PCT*@EXTRA_PCT, Y0, PCT, VY1,VY2,VY3    from DOWDS

-- FullDate,  ISOYearAndWeekNumber, Y0*PCT Value1, Y0, PCT, HW1, HW2, HW3,VY1,VY2,VY3,Category,Trend    from DOWDS
END	 

  


  
