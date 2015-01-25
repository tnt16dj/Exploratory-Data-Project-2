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

## Merge SCC data with NEI data
NEI <- merge(NEI,SCC,by="SCC")

## Subset combined NEI data to only records for Fuel Combustion
NEI <- NEI[grepl("Fuel Comb",NEI$EI.Sector),]

## Further subset NEI data to Coal based fuel sources
NEI <- NEI[grepl("Coal",NEI$EI.Sector) | grepl("Coal",NEI$Short.Name),]

## Summarize the data by year
NEI <- aggregate(Emissions ~ year,NEI, sum)

## load ggplot2 library
library(ggplot2)

## setup a png device to write to
png(filename="plot4.png",width=640,height=480,units="px",bg="transparent")

## set global plot preferences
par(bg="white",col="blue")

## Create the plot -- line plot, Emissions by Year
g <- ggplot(NEI,aes(year,Emissions))
g <- g + geom_smooth()
g <- g + labs(x="Year", y=expression(paste('PM'[2.5],' Emissions (tons)'))) ##label the x and y axis
g <- g + labs(title=expression(paste('Total US PM'[2.5],' Emissions from Coal Combustion Sources'))) ##add Title
g <- g + theme_light()
print(g)

## Turn off the png device
dev.off()