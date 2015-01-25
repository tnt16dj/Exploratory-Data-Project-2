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

## Subset the data for Baltimore City
NEI <- subset(NEI,fips == "24510")

## Convert type to factor
NEI$type <- as.factor(NEI$type)
## Convert year to factor
NEI$year <- as.factor(NEI$year)

## Summarize the data by year and type
NEI <- aggregate(Emissions ~ year + type,data=NEI,FUN="sum")

## setup a png device to write to
png(filename="plot3.png",width=640,height=480,units="px",bg="transparent")

## customize NEI column names
colnames(NEI) <- c("Year","Type","Emissions")

## load ggplot2 library
library(ggplot2)

## build the plot
g <- ggplot(NEI,aes(Year,Emissions,fill=Type)) ##specifies data frame, and aesthetics
g <- g + geom_bar(stat="identity") ##specifies that bars should be added to the plot
g <- g + facet_grid(facets=.~Type) ##sets up the facets for the plot
g <- g + labs(x="Year", y=expression(paste('PM'[2.5],' Emissions (tons)'))) ##label the x and y axis
g <- g + labs(title=expression(paste('Baltimore City PM'[2.5],' Emissions by Type'))) ##add Title
g <- g + labs(color="Emissions Type")
print(g)

## Turn off the png device
dev.off()