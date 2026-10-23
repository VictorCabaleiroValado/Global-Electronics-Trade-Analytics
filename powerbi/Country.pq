let
 Source = GoogleBigQuery.Database([UseStorageApi=false, BillingProject="victor-electronics-telecom21"]),
 Project = Source{[Name="victor-electronics-telecom21"]}[Data],
 Dataset = Project{[Name="electronics_telecom",Kind="Schema"]}[Data],
 Raw = Dataset{[Name="dim_country",Kind="Table"]}[Data],
 PreserveSource = Table.DuplicateColumn(Raw,"country_name","source_country_name"),
 CleanNames = Table.TransformColumns(PreserveSource, {{"country_name", each Text.Replace(Text.Replace(Text.Replace(Text.Replace(Text.Trim(_), "CÃ´te", "Côte"), "CuraÃ§ao", "Curaçao"), "Saint BarthÃ©lemy", "Saint Barthélemy"), "TÃ¼rkiye", "Türkiye"), type text}}),
 DisplayNames = Table.TransformColumns(CleanNames, {{"country_name", each Record.FieldOrDefault([China="China", #"China, Hong Kong SAR"="Hong Kong", #"China, Macao SAR"="Macao", #"Other Asia, nes"="Taiwan", USA="United States", #"Rep. of Korea"="South Korea", #"Dem. People's Rep. of Korea"="North Korea", #"Viet Nam"="Vietnam"], _, _), type text}}),
 DisplayRegion = Table.ReplaceValue(DisplayNames, each [region], each if Text.From([country_code]) = "490" then "Asia" else [region], Replacer.ReplaceValue, {"region"}),
 MapEligible = Table.ReplaceValue(DisplayRegion, each [map_eligible], each if Text.From([country_code]) = "490" then true else [map_eligible], Replacer.ReplaceValue, {"map_eligible"}),
 MapCode = Table.AddColumn(MapEligible,"map_iso3",each if Text.From([country_code]) = "490" then "TWN" else if [map_eligible] then [country_iso3] else null, type text)
in MapCode
