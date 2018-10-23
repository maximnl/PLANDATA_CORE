SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[CORE_WEEK](
	[WeekKey] [int] IDENTITY(1,1) NOT NULL,
	[ISOYearAndWeekNumber] [char](7) NOT NULL,
	[ISOWeekNumberOfYear] [tinyint] NOT NULL,
	[DateMin] [date] NULL,
	[DateMax] [date] NULL,
	[IsBankHoliday] [char](1) NULL,
	[IsFederalHoliday] [char](1) NULL,
	[IsLastDayOfMonth] [char](1) NULL,
	[IsoYear] [int] NOT NULL,
	[IsoYearWeek] [int] NOT NULL,
	[Source] [char](7) NULL,
	[week_string] [char](3) NULL,
	[Category] [varchar](20) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

