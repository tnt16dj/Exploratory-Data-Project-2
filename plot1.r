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

## Summarize the data by year
NEI <- aggregate(Emissions ~ year,NEI, sum)

## Scale the data to "millions", i.e. 10^6
NEI$Emissions <- NEI$Emissions/10^6

## setup a png device to write to
png(filename="plot1.png",width=640,height=480,units="px",bg="transparent")

## set global plot preferences
par(bg="white",col="blue")

## Create the plot -- line plot, Emissions by Year
with(NEI,
     plot(year,
          Emissions,
          type="b",
          xlab="Year",
          ylab=expression(paste('PM'[2.5],' Emissions (millions of tons)')),
          main=expression(paste('Total US Emissions of PM'[2.5],' from All Sources')),
          xlim=c(1999,2008),
          ylim=c(2,8)))

## Turn off the png device
dev.off()