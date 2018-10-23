SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CORE_INIT_DATE_POPULATE]
     @starting_dt DATE
     , @ending_dt DATE
     , @FiscalYearMonthsOffset int
AS

SET NOCOUNT ON
SET DATEFIRST 7     -- Standard for U.S. Week starts on Sunday
 
-- Standard Holidays
     -- New Years Day - Jan 1
     -- MLK Day - 3rd Monday in Jan
     -- Presidents Day - 3rd Monday in Feb
     -- Memorial Day - Last Mon in May
     -- Independence Day - Jul 4
      -- Labor Day - 1st Mon in Sep
     -- Columbus Day - 2nd Mon in Oct
     -- Veterans Day - Nov 11
     -- Thanksgiving Day - 4th Thurs in Nov
     -- Day after Thanksgiving - Day after 4th Thurs in Nov
      -- Christmas Eve - Dec 24
     -- Christmas Day - Dec 25

DECLARE @HolidayTable TABLE (HolidayKey int NOT NULL PRIMARY KEY
     , HolidayDate DATE NOT NULL
     , HolidayName varchar(50) NOT NULL
     , IsFedHoliday bit NOT NULL DEFAULT(0)
      , IsBankHoliday bit NOT NULL DEFAULT(0)
     , IsUSACorpHoliday bit NOT NULL DEFAULT(0)
     )

DECLARE @Yr int
     , @EndYr int
     , @Offset int
     , @WeekNumberInMonth int
     , @Jan1 DATE
     , @Feb1 DATE
     , @May1 DATE
     , @Sep1 DATE
     , @Oct1 DATE
     , @Nov1 DATE
     , @MemorialDay DATE
     , @ThanksgivingDay DATE
SET @Yr = DATEPART(yyyy, @starting_dt)
SET @EndYr = DATEPART(yyyy, @ending_dt)
 
WHILE @Yr <= @EndYr
BEGIN
IF @Yr > 1985
BEGIN
     SET @Jan1 = CAST(CAST(@Yr AS char(4)) + '0101' AS DATE)
     SET @Feb1 = CAST(CAST(@Yr AS char(4)) + '0201' AS DATE)
     SET @May1 = CAST(CAST(@Yr AS char(4)) + '0501' AS DATE)
      SET @Sep1 = CAST(CAST(@Yr AS char(4)) + '0901' AS DATE)
     SET @Oct1 = CAST(CAST(@Yr AS char(4)) + '1001' AS DATE)
     SET @Nov1 = CAST(CAST(@Yr AS char(4)) + '1101' AS DATE)

     -- New Years Day logic
      -- Could be celebrated on New Years Day, the Friday before, or the Monday after
     -- depending on whether the day falls on a weekend or not and the value of @FiscalYearMonthsOffset
     IF (DATEPART(dw, @Jan1) > 1) AND (DATEPART(dw, @Jan1) < 7)
      BEGIN
          INSERT INTO @HolidayTable
               SELECT CAST(CAST(@Yr AS char(4)) + '0101' as int)
                    , CAST(CAST(@Yr AS char(4)) + '0101' AS DATE)
                    , 'New Year''s Day'
                     , 1          -- IsFedHoliday
                    , 1          -- IsBankHoliday
                    , 1          -- IsUSACorpHoliday
     END
     IF (DATEPART(dw, @Jan1) = 1)
     BEGIN
           INSERT INTO @HolidayTable
               SELECT CAST(CAST(@Yr AS char(4)) + '0102' as int)
                    , CAST(CAST(@Yr AS char(4)) + '0102' AS DATE)
                    , 'New Year''s Day'
                     , 1          -- IsFedHoliday
                    , 1          -- IsBankHoliday
                    , 1          -- IsUSACorpHoliday
     END
     IF (DATEPART(dw, @Jan1) = 7)
     BEGIN
           -- For most banks, the fiscal year ends 12-31 and New Year's Day is celebrated in the New Year.
          IF @FiscalYearMonthsOffset = 0
          BEGIN
               -- When an organization's fiscal year ends on 12-31, and New Years falls on Saturday, New Years is observed on the following Monday.
                INSERT INTO @HolidayTable
                    SELECT CAST(CAST(@Yr - 1 AS char(4)) + '1231' as int)
                         , CAST(CAST(@Yr - 1 AS char(4)) + '1231' AS DATE)
                         , 'New Year''s Day'
                          , 1          -- IsFedHoliday
                         , 0          -- IsBankHoliday
                         , 0          -- IsUSACorpHoliday
               INSERT INTO @HolidayTable
                    SELECT CAST(CAST(@Yr AS char(4)) + '0103' as int)
                          , CAST(CAST(@Yr AS char(4)) + '0103' AS DATE)
                         , 'New Year''s Day'
                         , 0          -- IsFedHoliday
                         , 1          -- IsBankHoliday
                          , 1          -- IsUSACorpHoliday
          END
          ELSE
          BEGIN
               -- When an organization's fiscal year ends on a day other than 12-31, and New Years falls on Saturday, New Years is observed on the previous Friday.
                INSERT INTO @HolidayTable
                    SELECT CAST(CAST(@Yr - 1 AS char(4)) + '1231' as int)
                         , CAST(CAST(@Yr - 1 AS char(4)) + '1231' AS DATE)
                         , 'New Year''s Day'
                          , 1          -- IsFedHoliday
                         , 0          -- IsBankHoliday
                         , 1          -- IsUSACorpHoliday
               INSERT INTO @HolidayTable
                    SELECT CAST(CAST(@Yr AS char(4)) + '0103' as int)
                          , CAST(CAST(@Yr AS char(4)) + '0103' AS DATE)
                         , 'New Year''s Day'
                         , 0          -- IsFedHoliday
                         , 1          -- IsBankHoliday
                          , 0          -- IsUSACorpHoliday
          END
     END

     -- MLK Day logic
     -- 3rd Monday in Jan
     SET @offset = 2 - DATEPART(dw, @Jan1)
     SET @WeekNumberInMonth = 3
      INSERT INTO @HolidayTable
          SELECT CAST(CONVERT(char(8), DATEADD(dd, @offset + (@WeekNumberInMonth - CASE WHEN @offset >= 0 THEN 1 ELSE 0 END) * 7, @Jan1), 112) as int)
               , DATEADD(dd, @offset + (@WeekNumberInMonth - CASE WHEN @offset >= 0 THEN 1 ELSE 0 END) * 7, @Jan1)
                , 'MLK Day'
               , 1          -- IsFedHoliday
               , 1          -- IsBankHoliday
               , 1          -- IsUSACorpHoliday

     -- President's Day logic
      -- 3rd Monday in Feb
     SET @offset = 2 - DATEPART(dw, @Feb1)
     INSERT INTO @HolidayTable
          SELECT CAST(CONVERT(char(8), DATEADD(dd, @offset + (@WeekNumberInMonth - CASE WHEN @offset >= 0 THEN 1 ELSE 0 END) * 7, @Feb1), 112) as int)
                , DATEADD(dd, @offset + (@WeekNumberInMonth - CASE WHEN @offset >= 0 THEN 1 ELSE 0 END) * 7, @Feb1)
               , 'President''s Day'
               , 1          -- IsFedHoliday
                , 1          -- IsBankHoliday
               , 1          -- IsUSACorpHoliday

     -- Memorial Day logic
     -- Last Monday in May
     SET @MemorialDay = CASE DATEPART(dw, CAST(CAST(@Yr AS char(4)) + '0531' AS DATE))
                          WHEN 1
                         THEN CAST(CAST(@Yr AS char(4)) + '0525' AS DATE)
                         WHEN 2
                         THEN CAST(CAST(@Yr AS char(4)) + '0531' AS DATE)
                          WHEN 3
                         THEN CAST(CAST(@Yr AS char(4)) + '0530' AS DATE)
                         WHEN 4
                         THEN CAST(CAST(@Yr AS char(4)) + '0529' AS DATE)
                          WHEN 5
                         THEN CAST(CAST(@Yr AS char(4)) + '0528' AS DATE)
                         WHEN 6
                         THEN CAST(CAST(@Yr AS char(4)) + '0527' AS DATE)
                          ELSE CAST(CAST(@Yr AS char(4)) + '0526' AS DATE)
                    END
     INSERT INTO @HolidayTable
          SELECT CAST(CONVERT(char(8), @MemorialDay, 112) as int)
               , @MemorialDay
                , 'Memorial Day'
               , 1          -- IsFedHoliday
               , 1          -- IsBankHoliday
               , 1          -- IsUSACorpHoliday

     -- Independence Day logic
      -- Jul 4th of each year
     IF (DATEPART(dw, CAST(CAST(@Yr AS char(4)) + '0704' AS DATE)) > 1) AND (DATEPART(dw, CAST(CAST(@Yr AS char(4)) + '0704' AS DATE)) < 7)
     BEGIN
          INSERT INTO @HolidayTable
                SELECT CAST(CAST(@Yr AS char(4)) + '0704' as int)
                    , CAST(CAST(@Yr AS char(4)) + '0704' AS DATE)
                    , 'Independence Day'
                    , 1          -- IsFedHoliday
                     , 1          -- IsBankHoliday
                    , 1          -- IsUSACorpHoliday
     END
     IF (DATEPART(dw, CAST(CAST(@Yr AS char(4)) + '0704' AS DATE)) = 1)
     BEGIN
          INSERT INTO @HolidayTable
                SELECT CAST(CAST(@Yr AS char(4)) + '0705' as int)
                    , CAST(CAST(@Yr AS char(4)) + '0705' AS DATE)
                    , 'Independence Day'
                    , 1          -- IsFedHoliday
                     , 1          -- IsBankHoliday
                    , 1          -- IsUSACorpHoliday
     END
     IF (DATEPART(dw, CAST(CAST(@Yr AS char(4)) + '0704' AS DATE)) = 7)
     BEGIN
          INSERT INTO @HolidayTable
                SELECT CAST(CAST(@Yr AS char(4)) + '0703' as int)
                    , CAST(CAST(@Yr AS char(4)) + '0703' AS DATE)
                    , 'Independence Day'
                    , 1          -- IsFedHoliday
                     , 1          -- IsBankHoliday
                    , 1          -- IsUSACorpHoliday
     END

     -- Labor Day logic
     -- 1st Monday in September
     SET @offset = 2 - DATEPART(dw, @Sep1)
      SET @WeekNumberInMonth = 1
     INSERT INTO @HolidayTable
          SELECT CAST(CONVERT(char(8), DATEADD(dd, @offset + (@WeekNumberInMonth - CASE WHEN @offset >= 0 THEN 1 ELSE 0 END) * 7, @Sep1), 112) as int)
                , DATEADD(dd, @offset + (@WeekNumberInMonth - CASE WHEN @offset >= 0 THEN 1 ELSE 0 END) * 7, @Sep1)
               , 'Labor Day'
               , 1          -- IsFedHoliday
               , 1          -- IsBankHoliday
                , 1          -- IsUSACorpHoliday

     -- Columbus Day logic
     -- 2nd Monday in October
     -- Usually only observed by Fed Govt and Banks
     SET @offset = 2 - DATEPART(dw, @Oct1)
     SET @WeekNumberInMonth = 2
      INSERT INTO @HolidayTable
          SELECT CAST(CONVERT(char(8), DATEADD(dd, @offset + (@WeekNumberInMonth - CASE WHEN @offset >= 0 THEN 1 ELSE 0 END) * 7, @Oct1), 112) as int)
               , DATEADD(dd, @offset + (@WeekNumberInMonth - CASE WHEN @offset >= 0 THEN 1 ELSE 0 END) * 7, @Oct1)
                , 'Columbus Day'
               , 1          -- IsFedHoliday
               , 1          -- IsBankHoliday
               , 0          -- IsUSACorpHoliday

     -- Veterans Day logic
      -- October 11th of each year
     -- Usually only observed by Fed Govt and Banks
     IF (DATEPART(dw, CAST(CAST(@Yr AS char(4)) + '1111' AS DATE)) > 1) AND (DATEPART(dw, CAST(CAST(@Yr AS char(4)) + '1111' AS DATE)) < 7)
      BEGIN
          INSERT INTO @HolidayTable
               SELECT CAST(CAST(@Yr AS char(4)) + '1111' as int)
                    , CAST(CAST(@Yr AS char(4)) + '1111' AS DATE)
                    , 'Veterans Day'
                     , 1          -- IsFedHoliday
                    , 1          -- IsBankHoliday
                    , 0          -- IsUSACorpHoliday
     END
     IF (DATEPART(dw, CAST(CAST(@Yr AS char(4)) + '1111' AS DATE)) = 1)
      BEGIN
          INSERT INTO @HolidayTable
               SELECT CAST(CAST(@Yr AS char(4)) + '1112' as int)
                    , CAST(CAST(@Yr AS char(4)) + '1112' AS DATE)
                    , 'Veterans Day'
                     , 1          -- IsFedHoliday
                    , 1          -- IsBankHoliday
                    , 0          -- IsUSACorpHoliday
     END
     IF (DATEPART(dw, CAST(CAST(@Yr AS char(4)) + '1111' AS DATE)) = 7)
      BEGIN
          INSERT INTO @HolidayTable
               SELECT CAST(CAST(@Yr AS char(4)) + '1110' as int)
                    , CAST(CAST(@Yr AS char(4)) + '1110' AS DATE)
                    , 'Veterans Day'
                     , 1          -- IsFedHoliday
                    , 1          -- IsBankHoliday
                    , 0          -- IsUSACorpHoliday
     END

     -- Thanksgiving Day logic
     -- 4th Thursday of November
      SET @offset = 5 - DATEPART(dw, @Nov1)
     SET @WeekNumberInMonth = 4
     SET @ThanksgivingDay = DATEADD(dd, @offset + (@WeekNumberInMonth - CASE WHEN @offset >= 0 THEN 1 ELSE 0 END) * 7, @Nov1)
     INSERT INTO @HolidayTable
           SELECT CAST(CONVERT(char(8), @ThanksgivingDay, 112) as int)
               , @ThanksgivingDay
               , 'Thanksgiving Day'
               , 1          -- IsFedHoliday
               , 1          -- IsBankHoliday
                , 1          -- IsUSACorpHoliday

     -- Day after Thanksgiving Day logic
     -- Not observed by Fed Govt and Banks
     INSERT INTO @HolidayTable
          SELECT CAST(CONVERT(char(8), DATEADD(dd, 1, @ThanksgivingDay), 112) as int)
                , DATEADD(dd, 1, @ThanksgivingDay)
               , 'Day after Thanksgiving'
               , 0          -- IsFedHoliday
               , 0          -- IsBankHoliday
               , 1          -- IsUSACorpHoliday
 
     -- Christmas Eve logic
     -- Federal Govt and Banks do not celebrate Christmas Eve
     -- Logic can get complex when Christmas Day falls on a weekend.
     -- Using this logic, if Christmas Eve falls on Sunday, it will be observed on the following Tuesday.
      -- If Christmas Eve falls on Friday or Saturday, it will be observed on 12-23.
     -- Many companies do not use the following logic.
     IF (DATEPART(dw, CAST(CAST(@Yr AS char(4)) + '1224' AS DATE)) > 1) AND (DATEPART(dw, CAST(CAST(@Yr AS char(4)) + '1224' AS DATE)) < 6)
      BEGIN
          INSERT INTO @HolidayTable
               SELECT CAST(CAST(@Yr AS char(4)) + '1224' as int)
                    , CAST(CAST(@Yr AS char(4)) + '1224' AS DATE)
                    , 'Christmas Eve'
                     , 0          -- IsFedHoliday
                    , 0          -- IsBankHoliday
                    , 1          -- IsUSACorpHoliday
     END
     IF (DATEPART(dw, CAST(CAST(@Yr AS char(4)) + '1224' AS DATE)) = 1)
      BEGIN
          INSERT INTO @HolidayTable
               SELECT CAST(CAST(@Yr AS char(4)) + '1226' as int)
                    , CAST(CAST(@Yr AS char(4)) + '1226' AS DATE)
                    , 'Christmas Eve'
                     , 0          -- IsFedHoliday
                    , 0          -- IsBankHoliday
                    , 1          -- IsUSACorpHoliday
     END
     IF (DATEPART(dw, CAST(CAST(@Yr AS char(4)) + '1224' AS DATE)) > 5)
      BEGIN
          INSERT INTO @HolidayTable
               SELECT CAST(CAST(@Yr AS char(4)) + '1223' as int)
                    , CAST(CAST(@Yr AS char(4)) + '1223' AS DATE)
                    , 'Christmas Eve'
                     , 0          -- IsFedHoliday
                    , 0          -- IsBankHoliday
                    , 1          -- IsUSACorpHoliday
     END

     -- Christmas Day logic
     IF (DATEPART(dw, CAST(CAST(@Yr AS char(4)) + '1225' AS DATE)) > 1) AND (DATEPART(dw, CAST(CAST(@Yr AS char(4)) + '1225' AS DATE)) < 7)
      BEGIN
          INSERT INTO @HolidayTable
               SELECT CAST(CAST(@Yr AS char(4)) + '1225' as int)
                    , CAST(CAST(@Yr AS char(4)) + '1225' AS DATE)
                    , 'Christmas Day'
                     , 1          -- IsFedHoliday
                    , 1          -- IsBankHoliday
                    , 1          -- IsUSACorpHoliday
     END
     IF (DATEPART(dw, CAST(CAST(@Yr AS char(4)) + '1225' AS DATE)) = 1)
      BEGIN
          INSERT INTO @HolidayTable
               SELECT CAST(CAST(@Yr AS char(4)) + '1226' as int)
                    , CAST(CAST(@Yr AS char(4)) + '1226' AS DATE)
                    , 'Christmas Day'
                     , 1          -- IsFedHoliday
                    , 1          -- IsBankHoliday
                    , 1          -- IsUSACorpHoliday
     END
     IF (DATEPART(dw, CAST(CAST(@Yr AS char(4)) + '1225' AS DATE)) = 7)
      BEGIN
          INSERT INTO @HolidayTable
               SELECT CAST(CAST(@Yr AS char(4)) + '1224' as int)
                    , CAST(CAST(@Yr AS char(4)) + '1224' AS DATE)
                    , 'Christmas Day'
                     , 1          -- IsFedHoliday
                    , 1          -- IsBankHoliday
                    , 1          -- IsUSACorpHoliday
     END

     END
SET @Yr = @Yr + 1
END

 DECLARE @Control_Date DATE     --Current date in loop

SET @Control_Date = @starting_dt

WHILE @Control_Date <= @ending_dt
BEGIN
     SET @Yr = DATEPART(yyyy, @Control_Date)
     INSERT INTO [CORE_DATE] ([DateKey]
                          , [FullDate]
                         , [MonthNumberOfYear]
                         , [MonthNumberOfQuarter]
                         , [ISOYearAndWeekNumber]
                         , ISOYearAndWeekInteger
                          , [ISOWeekNumberOfYear]
                         , [SSWeekNumberOfYear]
                         , [ISOWeekNumberOfQuarter_454_Pattern]
                         , [SSWeekNumberOfQuarter_454_Pattern]
                          , [SSWeekNumberOfMonth]
                         , [DayNumberOfYear]
                         , [DaysSince1900]
                         , [DaysSince2000]
                         , [DayNumberOfFiscalYear]
                          , [DayNumberOfQuarter]
                         , [DayNumberOfMonth]
                         , [DayNumberOfWeek_Sun_Start]
                         , [MonthName]
                         , [MonthNameAbbreviation]
                          , [DayName]
                         , [DayNameAbbreviation]
                         , [CalendarYear]
                         , [CalendarYearMonth]
                         , [CalendarYearQtr]
                          , [CalendarSemester]
                         , [CalendarQuarter]
                         , [FiscalYear]
                         , [FiscalMonth]
                         , [FiscalQuarter]
                          , [FiscalYearMonth]
                         , [FiscalYearQtr]
                         , [QuarterNumber]
                         , [YYYYMMDD]
                         , [MM/DD/YYYY]
                          , [YYYY/MM/DD]
                         , [YYYY-MM-DD]
                         , [MonDDYYYY]
                         , [IsLastDayOfMonth]
                         , [IsWeekday]
                         , [IsWeekend]
						 , [Source]
               )

     SELECT CAST(CONVERT(char(8), @Control_Date,112) as int) AS [DateKey]
           , @Control_Date AS [FullDate]
          , DATEPART(mm, @Control_Date) AS [MonthNumberOfYear]
          , CASE DATEPART(mm, @Control_Date)
                    WHEN 1 THEN 1
                    WHEN 2 THEN 2
                     WHEN 3 THEN 3
                    WHEN 4 THEN 1
                    WHEN 5 THEN 2
                    WHEN 6 THEN 3
                    WHEN 7 THEN 1
                    WHEN 8 THEN 2
                     WHEN 9 THEN 3
                    WHEN 10 THEN 1
                    WHEN 11 THEN 2
                    ELSE 3
               END AS [MonthNumberOfQuarter]
          , CASE
               WHEN DATEPART(mm, @Control_Date) = 1 AND DATEPART(isoww, @Control_Date) > 50
                THEN CAST(@Yr - 1 AS char(4)) + 'W' + RIGHT('0' + CAST(DATEPART(isoww, @Control_Date) AS varchar(2)), 2)
               WHEN DATEPART(mm, @Control_Date) = 12 AND DATEPART(isoww, @Control_Date) < 40
                THEN CAST(@Yr + 1 AS char(4)) + 'W' + RIGHT('0' + CAST(DATEPART(isoww, @Control_Date) AS varchar(2)), 2)
               ELSE CAST(@Yr AS char(4)) + 'W' + RIGHT('0' + CAST(DATEPART(isoww, @Control_Date) AS varchar(2)), 2)
                END AS [ISOYearAndWeekNumber]
        , CASE
                       WHEN DATEPART(mm, @Control_Date) = 1 AND DATEPART(isoww, @Control_Date) > 50
                       THEN (@Yr - 1) *100 + DATEPART(isoww, @Control_Date) 
                       WHEN DATEPART(mm, @Control_Date) = 12 AND DATEPART(isoww, @Control_Date) < 40
                       THEN (@Yr + 1) * 100 + DATEPART(isoww, @Control_Date)
                       ELSE @Yr *100 + DATEPART(isoww, @Control_Date) 
                       END AS [ISOYearAndWeekInteger]
          , DATEPART(isoww, @Control_Date) AS [ISOWeekNumberOfYear]
          , DATEPART(wk, @Control_Date) AS [SSWeekNumberOfYear]
          , CASE
               WHEN DATEPART(isoww, @Control_Date) < 14
                THEN DATEPART(isoww, @Control_Date)
               WHEN DATEPART(isoww, @Control_Date) > 13 AND DATEPART(isoww, @Control_Date) < 27
               THEN DATEPART(isoww, @Control_Date) - 13
               WHEN DATEPART(isoww, @Control_Date) > 26 AND DATEPART(isoww, @Control_Date) < 40
                THEN DATEPART(isoww, @Control_Date) - 26
               ELSE DATEPART(isoww, @Control_Date) - 39
               END AS [ISOWeekNumberOfQuarter_454_Pattern]
          , CASE
               WHEN DATEPART(wk, @Control_Date) < 14
                THEN DATEPART(wk, @Control_Date)
               WHEN DATEPART(wk, @Control_Date) > 13 AND DATEPART(wk, @Control_Date) < 27
               THEN DATEPART(wk, @Control_Date) - 13
               WHEN DATEPART(wk, @Control_Date) > 26 AND DATEPART(wk, @Control_Date) < 40
                THEN DATEPART(wk, @Control_Date) - 26
               ELSE DATEPART(wk, @Control_Date) - 39
               END AS [SSWeekNumberOfQuarter_454_Pattern]
          , DATEDIFF(wk, DATEADD(mm, DATEDIFF(mm, 0, @Control_Date), 0), @Control_Date) + 1 AS [SSWeekNumberOfMonth]
           , DATEPART(dy, @Control_Date) AS [DayNumberOfYear]
          , DATEDIFF(dd, '18991231', @Control_Date) AS [DaysSince1900]
          , DATEDIFF(dd, '19991231', @Control_Date) AS [DaysSince2000]
           , CASE
               -- 0ffset < 0 and start of fy < current year
               WHEN YEAR(DATEADD(mm, @FiscalYearMonthsOffset, @Control_Date)) < @Yr
                    AND @FiscalYearMonthsOffset < 0
                THEN DATEPART(dy, @Control_Date)
                         + DATEPART(dy,
                         -- Last day of previous year
                         CAST(CAST(YEAR(DATEADD(mm, @FiscalYearMonthsOffset, @Control_Date)) AS CHAR(4)) + '1231' AS DATETIME))
                          - DATEPART(dy,
                         -- Start date of Fiscal year
                         DATEADD(mm, 1, CAST(CAST(CAST(YEAR(DATEADD(mm, @FiscalYearMonthsOffset, @Control_Date)) AS char(4))
                          + RIGHT('00' + CAST(@FiscalYearMonthsOffset * -1 AS varchar(2)), 2) + '01' AS char(8)) AS DATETIME))
                         - 1)
               -- 0ffset > 0 and start of fy < current year
                WHEN YEAR(DATEADD(mm, @FiscalYearMonthsOffset, @Control_Date)) - 1 < @Yr
                    AND @FiscalYearMonthsOffset > 0
               THEN DATEPART(dy, @Control_Date)
                         + DATEPART(dy,
                          -- Last day of previous year
                         CAST(CAST(YEAR(DATEADD(mm, @FiscalYearMonthsOffset, @Control_Date)) - 1 AS CHAR(4)) + '1231' AS DATETIME))
                         - DATEPART(dy,
                          -- Start date of Fiscal year
                         CAST(CAST(CAST(YEAR(DATEADD(mm, @FiscalYearMonthsOffset, @Control_Date)) - 1 AS char(4))
                         + RIGHT('00' + CAST(13 - @FiscalYearMonthsOffset AS varchar(2)), 2) + '01' AS char(8)) AS DATETIME)
                          - 1)
               -- 0ffset < 0 and start of fy = current year
               WHEN YEAR(DATEADD(mm, @FiscalYearMonthsOffset, @Control_Date)) = @Yr
                    AND @FiscalYearMonthsOffset < 0
                THEN DATEPART(dy, @Control_Date)
                         - DATEPART(dy,
                         -- Start date of Fiscal year
                         DATEADD(mm, 1, CAST(CAST(CAST(YEAR(DATEADD(mm, @FiscalYearMonthsOffset, @Control_Date)) AS char(4))
                          + RIGHT('00' + CAST(@FiscalYearMonthsOffset * -1 AS varchar(2)), 2) + '01' AS char(8)) AS DATETIME))
                         - 1)
               -- 0ffset > 0 and start of fy = current year
                WHEN YEAR(DATEADD(mm, @FiscalYearMonthsOffset, @Control_Date)) - 1 = @Yr
                    AND @FiscalYearMonthsOffset > 0
               THEN DATEPART(dy, @Control_Date)
                         - DATEPART(dy,
                          -- Start date of Fiscal year
                         CAST(CAST(CAST(YEAR(DATEADD(mm, @FiscalYearMonthsOffset, @Control_Date)) - 1 AS char(4))
                         + RIGHT('00' + CAST(13 - @FiscalYearMonthsOffset AS varchar(2)), 2) + '01' AS char(8)) AS DATETIME)
                          - 1)
               ELSE DATEPART(dy, @Control_Date)
               END AS [DayNumberOfFiscalYear]
          , CASE
               WHEN DATEPART(mm, @Control_Date) = 1
                    OR DATEPART(mm, @Control_Date) = 4
                     OR DATEPART(mm, @Control_Date) = 7
                    OR DATEPART(mm, @Control_Date) = 10
               THEN DATEPART(day, @Control_Date)
               WHEN DATEPART(mm, @Control_Date) = 2
                     OR DATEPART(mm, @Control_Date) = 5
                    OR DATEPART(mm, @Control_Date) = 8
                    OR DATEPART(mm, @Control_Date) = 11
               THEN DATEPART(day, @Control_Date)
                          + DAY(DATEADD (m, 1, DATEADD (d, 1 - DAY(CAST(CAST(@Yr AS char(4))
                         + RIGHT('0' + CAST(DATEPART(mm, @Control_Date) - 1 AS varchar(2)), 2) + '01' AS DATE))
                          , CAST(CAST(@Yr AS char(4)) + RIGHT('0' + CAST(DATEPART(mm, @Control_Date) - 1 AS varchar(2)), 2) + '01' AS DATETIME)))
                         - 1)
               WHEN DATEPART(mm, @Control_Date) = 3
                     OR DATEPART(mm, @Control_Date) = 6
                    OR DATEPART(mm, @Control_Date) = 9
                    OR DATEPART(mm, @Control_Date) = 12
               THEN DATEPART(day, @Control_Date)
                          + DAY(DATEADD (m, 1, DATEADD (d, 1 - DAY(CAST(CAST(@Yr AS char(4))
                         + RIGHT('0' + CAST(DATEPART(mm, @Control_Date) - 1 AS varchar(2)), 2) + '01' AS DATE))
                          , CAST(CAST(@Yr AS char(4)) + RIGHT('0' + CAST(DATEPART(mm, @Control_Date) - 1 AS varchar(2)), 2) + '01' AS DATETIME)))
                         - 1)
                         + DAY(DATEADD (m, 1, DATEADD (d, 1 - DAY(CAST(CAST(@Yr AS char(4))
                          + RIGHT('0' + CAST(DATEPART(mm, @Control_Date) - 2 AS varchar(2)), 2) + '01' AS DATE))
                         , CAST(CAST(@Yr AS char(4)) + RIGHT('0' + CAST(DATEPART(mm, @Control_Date) - 2 AS varchar(2)), 2) + '01' AS DATETIME)))
                          - 1)
               END AS [DayNumberOfQuarter]
          , DATEPART(day, @Control_Date) AS [DayNumberOfMonth]
          , DATEPART(dw, @Control_Date) AS [DayNumberOfWeek_Sun_Start]
          , DATENAME(month, @Control_Date) AS [MonthName]
           , LEFT(DATENAME(month, @Control_Date), 3) AS [MonthNameAbbreviation]
          , DATENAME(weekday, @Control_Date) AS [DayName]
          , LEFT(DATENAME(weekday, @Control_Date), 3) AS [DayNameAbbreviation]
           , @Yr AS [CalendarYear]
          , CONVERT(varchar(7), @Control_Date, 126) AS [CalendarYearMonth]
          , CAST(@Yr AS char(4)) + '-' + RIGHT('0' + CAST(DATEPART(qq, @Control_Date) AS char(1)), 2) AS [CalendarYearQuarter]
           , CASE (DATEPART(mm, @Control_Date))
                    WHEN 1 THEN 1
                    WHEN 2 THEN 1
                    WHEN 3 THEN 1
                    WHEN 4 THEN 1
                    WHEN 5 THEN 1
                     WHEN 6 THEN 1
                    ELSE 2
               END AS [CalendarSemester]
          , DATEPART(qq, @Control_Date) AS [CalendarQuarter]
          , DATEPART(yyyy, DATEADD(mm, @FiscalYearMonthsOffset, @Control_Date)) AS [FiscalYear]
           , DATEPART(mm, DATEADD(mm, @FiscalYearMonthsOffset, @Control_Date)) AS [FiscalMonth]
          , DATEPART(qq, DATEADD(mm, @FiscalYearMonthsOffset, @Control_Date)) AS [FiscalQuarter]
          , CAST(DATEPART(yyyy, DATEADD(mm, @FiscalYearMonthsOffset, @Control_Date)) AS char(4)) + '-'
                     + RIGHT('0' + CAST(DATEPART(mm, DATEADD(mm, @FiscalYearMonthsOffset, @Control_Date)) AS varchar(2)), 2) AS [FiscalYearMonth]
          , CAST(DATEPART(yyyy, DATEADD(mm, @FiscalYearMonthsOffset, @Control_Date)) AS char(4)) + 'Q'
                     + RIGHT('0' + CAST(DATEPART(qq, DATEADD(mm, @FiscalYearMonthsOffset, @Control_Date)) AS varchar(2)), 2) AS [FiscalYearQtr]
          , CASE
               WHEN @Control_Date >= '19000101'
                THEN ((@Yr - 1900) * 4) + DATEPART(qq, @Control_Date)
               ELSE ((@Yr - 1900) * 4) - (5 - DATEPART(qq, @Control_Date))
               END AS [QuarterNumber]
          , CONVERT(varchar(8), @Control_Date, 112) AS [YYYYMMDD]
           , CONVERT(varchar(10), @Control_Date, 101) AS [MM/DD/YYYY]
          , CONVERT(varchar(10), @Control_Date, 111) AS [YYYY/MM/DD]
          , REPLACE(CONVERT(varchar(10), @Control_Date, 111), '/', '-') AS [YYYY-MM-DD]
           , LEFT(DATENAME(month, @Control_Date), 3) + ' ' +
               RIGHT('0' + CAST(DATEPART(dd, @Control_Date) AS varchar(2)), 2) + ' ' +
               CAST(@Yr AS CHAR(4)) AS [MonDDYYYY]
           , CASE
               WHEN @Control_Date = DATEADD(d, -day(DATEADD(mm, 1, @Control_Date)), DATEADD(mm, 1, @Control_Date))
               THEN 'Y'
               ELSE 'N'
               END AS [IsLastDayOfMonth]
           , CASE DATEPART(dw, @Control_Date)
                    WHEN 1
                    THEN 'N'
                    WHEN 7
                    THEN 'N'
                    ELSE 'Y'
                END AS [IsWeekday]
          , CASE DATEPART(dw, @Control_Date)
                    WHEN 1
                    THEN 'Y'
                    WHEN 7
                    THEN 'Y'
                     ELSE 'N'
               END AS [IsWeekend]
			, 'PLANSIS' as [Source]

     SET @Control_Date = DATEADD(dd, 1, @Control_Date)
END

UPDATE dateTbl
     SET dateTbl.[IsWorkday] = CASE
                         WHEN dateTbl.IsWeekday = 'Y'
                               AND ISNULL(holTbl.IsUSACorpHoliday, 0) = 0
                         THEN 'Y'
                         ELSE 'N'
                         END
          , dateTbl.[IsFederalHoliday] = CASE
                          WHEN ISNULL(holTbl.IsFedHoliday, 0) = 1
                         THEN 'Y'
                         ELSE 'N'
                         END
          , dateTbl.[IsBankHoliday] = CASE
                          WHEN ISNULL(holTbl.IsBankHoliday, 0) = 1
                         THEN 'Y'
                         ELSE 'N'
                         END
          , dateTbl.[IsCompanyHoliday] = CASE
                          WHEN ISNULL(holTbl.IsUSACorpHoliday, 0) = 1
                         THEN 'Y'
                         ELSE 'N'
                         END
     FROM dbo.[CORE_DATE] dateTbl
           LEFT OUTER JOIN @HolidayTable holTbl
               ON dateTbl.[DateKey] = holTbl.HolidayKey
     WHERE DateKey BETWEEN CAST(CONVERT(varchar(8), @starting_dt, 112) AS int) AND CAST(CONVERT(varchar(8), @ending_dt, 112) AS int)
 
 update [dbo].[CORE_DATE]
set IsoYear=left([ISOYearAndWeekNumber],4)
,IsoYearWeek=left([ISOYearAndWeekNumber],4)*100+ISOWeekNumberOfYear
,WeekKey= (DATEDIFF(dd, '19000101', [fulldate]) /7)
,[DateKeyString8]=[DateKey]


  -- update weeklag with respect to the current week (make this part repeating in a dayly job)
    declare @curWeekKey int
    SET @curWeekKey=(select W.WeekKey
    from [dbo].[dim_date] D
    inner join [dbo].[dim_week] W on D.ISOYearAndWeekNumber=W.ISOYearAndWeekNumber
    where D.FullDate=convert(date,GetDate()))

    update [dbo].[dim_date]
    set WeekLag=WeekKey-@curWeekKey



 -- populate week

 
SET IDENTITY_INSERT [dbo].[CORE_WEEK] ON

INSERT INTO [dbo].[CORE_WEEK] 
(
[WeekKey]
,[ISOYearAndWeekNumber]
,[ISOWeekNumberOfYear]
,[DateMin]
,[DateMax]
,[IsBankHoliday]
,[IsFederalHoliday]
,[IsLastDayOfMonth]
,[IsoYear]
,[IsoYearWeek]
,[Source])
select
min([WeekKey])
,ISOYearAndWeekNumber
,ISOWeekNumberOfYear
,MIN(FullDate) AS DateMin
,MAX(FullDate) AS DateMax
,MAX(IsBankHoliday) AS IsBankHoliday
,MAX(IsFederalHoliday) AS IsFederalHoliday
,MAX(IsLastDayOfMonth) AS IsLastDayOfMonth
,MIN(ISOYear) as IsoYear
,MIN(IsoYearWeek) as IsoYearWeek
,max(source) as Source
FROM [dbo].[CORE_DATE]
GROUP BY ISOYearAndWeekNumber, ISOWeekNumberOfYear
ORDER BY ISOYearAndWeekNumber

 update D
  set D.WeekKey=W.WeekKey
  from [dbo].[CORE_DATE] D
  inner join [dbo].[dim_week] W on D.ISOYearAndWeekNumber=W.ISOYearAndWeekNumber
