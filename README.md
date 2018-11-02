# PLANDATA_CORE

Corporate reports are made in a variety of ways using variety of systems. A modern corporate report requires data scope definition, data selection, filtering, calculations, laoyt and even handmade corrections or copy paste data from other reports. Reports can be very complex but they are percieved as a single version of truth by the business. However, few people realise the fact that the information in a report is available only via the report, only! Why it that? Because a report mixes data with formating and layout. This mix presents a fundamental bottleneck for scalability, agilense of development, data integrity , analysis and forecasting applications. We inverst a lot of effort, time and money in something we cannot reuse, enhance and share. 

After 10 years of practical expirience in corporate reporting and intensitve development I can state that corporate reporting can be done in a easier, more collaborative, more sustainable and much more fun way. Here on github I introduce a data framework that resolve this fundamental problem. We need to step out from the old report-datawarehouse tandem world, look around and think about a better management information wordl 2. This new world should make analytical applications much easier just as we all want it. We need to think of new ways to interact between reporting, data and business users. PLANDATA_CORE is a reporting and forecasting data framework that puts this complex interaction process on rails of well defined modules. I believe it is a game changer and majority of corporate report will recognise the need for an extra analytical reporting layour. Together at Github we will move forward and be ready with a solution when people get amazed with the speed and quality we deliver. We have time to stuff this framework with many analytical features to move forward as I promise you will have more fun and generate more free time for yourself while achieving amasing results. Join the project, let me know what you think, what are your experiences are. We need developers, designers, forecasters, analysts, business users.  

PLANDATA_CORE can be used for Management information applications such as force management (WFM), project management, corporate reporting. The framework allows to overcome also a number of less  fundametal limitations of old reports-datawarehouses tandem world such as :
- slow execution jobs   (datawarehouses are huge, complex and something constantly goes wrong),
- slow development time (we cannot extend a monster in an agile way - develop, test, deliver in hours), 
- lack of release management (datawharehouses and reports lack or do not have professional release management) , 
- hidden metadata (many reports are based on complex and chainging filters for dimensions), 
- one way road (we cannot easily update datawharehouse data and keep our planning data in a database), 
- data scope limitations (limitations of cubes to interact with each other, databases walls), 
- lack of plan metadata management (lists and excels everywhere) 
- incompletness of DW (datawarehouses are good on details but miss some crusial data such as budgeting, forecast, call center data, HR data, project management data)
. 
I will publish an article on LinkedIn soon about present Management Information shortcummings and share my view more in depth. 

In the nutshell the framework allows 3 things:
1. Automate pulling of data from any database source, text file source or datawarehouse. 
2. Convert data into extended time series data and do all kinds of operations on time series data, combine them, subtract, convert, forecast
3. Control 1-2 from an easy to use application such that most of ICT tasks can be done by a business person. A your company and your approach grow, easiness to change things becomes very important to catch up with the business and grow the business.


So this is work in progress, as I have to pull different parts from various production systems, but hier is a first batch, some basic dimensions  that we will need very soon. It is mainly plain SQL Server SQL. For configuration of import data jobs I use MS Access as it is available to most of business users. For reporting I will shouw how to build SSAS on top and connect Excel or SSRS reports. 

if you like the ideas please feel free to catch up. I live in Arnhem, The Netherlands. Check my LinkedIn, lets get connected and help each other. The World is big!

With kind regards
Maxim Ivashkov
