SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[CORE_DATE](
	[DaysSince2000] [smallint] NOT NULL,
	[DateKey] [int] NOT NULL,
	[FullDate] [date] NOT NULL,
	[MonthNumberOfYear] [tinyint] NOT NULL,
	[MonthNumberOfQuarter] [tinyint] NOT NULL,
	[ISOYearAndWeekInteger] [int] NULL,
	[ISOYearAndWeekNumber] [char](7) NOT NULL,
	[ISOWeekNumberOfYear] [tinyint] NOT NULL,
	[SSWeekNumberOfYear] [tinyint] NOT NULL,
	[ISOWeekNumberOfQuarter_454_Pattern] [tinyint] NOT NULL,
	[SSWeekNumberOfQuarter_454_Pattern] [tinyint] NOT NULL,
	[SSWeekNumberOfMonth] [tinyint] NOT NULL,
	[DayNumberOfYear] [smallint] NOT NULL,
	[DaysSince1900] [int] NOT NULL,
	[DayNumberOfFiscalYear] [smallint] NOT NULL,
	[DayNumberOfQuarter] [smallint] NOT NULL,
	[DayNumberOfMonth] [tinyint] NOT NULL,
	[DayNumberOfWeek_Sun_Start] [tinyint] NOT NULL,
	[MonthName] [varchar](10) NOT NULL,
	[MonthNameAbbreviation] [char](3) NOT NULL,
	[DayName] [varchar](10) NOT NULL,
	[DayNameAbbreviation] [char](3) NOT NULL,
	[CalendarYear] [smallint] NOT NULL,
	[CalendarYearMonth] [char](7) NOT NULL,
	[CalendarYearQtr] [char](7) NOT NULL,
	[CalendarSemester] [tinyint] NOT NULL,
	[CalendarQuarter] [tinyint] NOT NULL,
	[FiscalYear] [smallint] NOT NULL,
	[FiscalMonth] [tinyint] NOT NULL,
	[FiscalQuarter] [tinyint] NOT NULL,
	[FiscalYearMonth] [char](7) NOT NULL,
	[FiscalYearQtr] [char](8) NOT NULL,
	[QuarterNumber] [int] NOT NULL,
	[YYYYMMDD] [char](8) NOT NULL,
	[MM/DD/YYYY] [char](10) NOT NULL,
	[YYYY/MM/DD] [char](10) NOT NULL,
	[YYYY-MM-DD] [char](10) NOT NULL,
	[DD-MM-YYYY] [char](10) NULL,
	[MonDDYYYY] [char](11) NOT NULL,
	[IsLastDayOfMonth] [char](1) NOT NULL,
	[IsWeekday] [char](1) NOT NULL,
	[IsWeekend] [char](1) NOT NULL,
	[IsWorkday] [char](1) NOT NULL CONSTRAINT [DF__dim_date__IsWork__1]  DEFAULT ('N'),
	[IsFederalHoliday] [char](1) NOT NULL CONSTRAINT [DF__dim_date__2]  DEFAULT ('N'),
	[IsBankHoliday] [char](1) NOT NULL CONSTRAINT [DF__dim_date__3]  DEFAULT ('N'),
	[IsCompanyHoliday] [char](1) NOT NULL CONSTRAINT [DF__dim_date__4]  DEFAULT ('N'),
	[Source] [char](7) NULL,
	[IsoYear] [int] NULL,
	[IsoYearWeek] [int] NULL,
	[DateKeyString8] [char](8) NULL,
	[DayNumberOfWeek] [tinyint] NULL,
	[ISOYearAndWeekShort] [char](5) NULL,
	[WeekKey] [int] NULL,
	[WeekLag] [int] NULL,
 CONSTRAINT [PK_dim_date_DateKey1] PRIMARY KEY CLUSTERED 
(
	[DateKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO
