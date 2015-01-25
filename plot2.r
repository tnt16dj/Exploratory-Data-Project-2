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

## Summarize the data by year
NEI <- aggregate(Emissions ~ year,NEI, sum)

## setup a png device to write to
png(filename="plot2.png",width=640,height=480,units="px",bg="transparent")

## set global plot preferences
par(bg="white",col="blue")

## Create the plot -- line plot, Emissions by Year
with(NEI,
     plot(year,
          Emissions,
          type="b",
          xlab="Year",
          ylab=expression(paste('PM'[2.5],' Emissions (tons)')),
          main=expression(paste('Total Baltimore City Emissions of PM'[2.5],' from All Sources')),
          xlim=c(1999,2008),
          ylim=c(1600,3800)))

## Turn off the png device
dev.off()