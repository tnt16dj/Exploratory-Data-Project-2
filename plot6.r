## check if data is downloaded, if not download
if (!file.exists("./EPAData.zip")) {
        ## download the EPA Data file.
        fileURL <- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip"
        download.file(fileURL,destfile="./EPAData.zip",method="curl")
        
        ## unzip the file
        unzip("./EPAData.zip")
}

## Read the data into memory
NEI <- readRDS("summarySCC_PM25.rds")
SCC <- readRDS("Source_Classification_Code.rds")

## Subset the SCC data to the desired Columns (SCC,Data.Category,Short.Name,EI.Sector)
SCC <- subset(SCC,select=c("SCC","Data.Category","Short.Name","EI.Sector"))

## Subset the data for Baltimore City and Los Angeles County
NEI <- subset(NEI,fips == "24510" | fips == "06037")

library(plyr)

## revalue fips to desired names
NEI$fips <- revalue(NEI$fips,c("06037"="Los Angeles County","24510"="Baltimore City"))

## Merge SCC data with NEI data
NEI <- merge(NEI,SCC,by="SCC")

## Subset combined NEI data to select all automobile-based records
NEI <- NEI[grepl("Mobile - On-Road",NEI$EI.Sector),]

## Summarize the data by year and fips (i.e. area)
NEI <- aggregate(Emissions ~ year + fips,data=NEI,FUN="sum")

## Convert fips to factor
NEI$fips <- as.factor(NEI$fips)

## establish the 1999 index values for each city that will be used to normalize the data
baltimore_index <- NEI[NEI$year == 1999 & NEI$fips == "Baltimore City",3]
losangeles_index <- NEI[NEI$year == 1999 & NEI$fips == "Los Angeles County",3]

## Adjust Column Names
colnames(NEI) <- c("Year","Location","Emissions")

## Normalize Emissions to a Percentage calc'd against 1999 baseline
NEI[NEI$Location == "Baltimore City",3] <- sapply(NEI[NEI$Location == "Baltimore City",3],function(elem) (elem/baltimore_index)*100)
NEI[NEI$Location == "Los Angeles County",3] <- sapply(NEI[NEI$Location == "Los Angeles County",3],function(elem) (elem/losangeles_index)*100)

## load ggplot2
library(ggplot2)        
        
## setup a png device to write to
png(filename="plot6.png",width=640,height=480,units="px",bg="transparent")

## set global plot preferences
par(bg="white",col="blue")

## Create the plot -- line plot, Emissions by Year
g <- ggplot(NEI,aes(Year,Emissions,fill=Location))
g <- g + geom_smooth(aes(color=Location))
g <- g + labs(x="Year", y=expression(paste('PM'[2.5],' Emissions % (vs 1999 Levels)'))) ##label the x and y axis
g <- g + labs(title=expression(paste('% Change in Auto PM'[2.5],' Emissions (vs 1999 Baseline)'))) ##add Title
g <- g + theme_light()
print(g)

## Turn off the png device
dev.off()