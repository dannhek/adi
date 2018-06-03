#ADI Processing - Aggregation

##Initialization
rm(list=ls())
for (pkg in c('plyr','stringr','tools')) {
	if (!is.element(pkg,installed.packages()[,1])) {
		r <- getOption("repos")
		r["CRAN"] <- "http://cran.us.r-project.org"
		options(repos = r)
		rm(r)
		install.packages(pkg)
	}
	library(pkg,character.only = T)
} ; rm(pkg)
`%ni%` <- Negate(`%in%`)

##Download Files If Needed
setwd('~/Desktop/ADI/')
adi.file <- 'zip4_dep_index.csv'
zip.file <- paste0(getwd(),'/adi.zip')

if (!file.exists(adi.file)) {
	download.file(url='https://www.hipxchange.org/sites/default/files/Area%20Deprivation%20Index%20Dataset%20-%20All%20Zip%20Codes.zip',
				  destfile = zip.file)
	unzip(zip.file)
	file.remove(zip.file)
}
if (!file.exists('free-zipcode-database-Primary.csv')) {
	download.file(url = 'http://federalgovernmentzipcodes.us/free-zipcode-database-Primary.csv',
				  destfile = 'free-zipcode-database-Primary.csv')
}

##Load, parse, and merge Files
adi.df.raw <- read.csv(adi.file)
adi.df$Zipcode <- substr(adi.df.raw$zip_code_plus4_txt,1,5)

adi.df <- ddply(.data = adi.df.raw,
				.variables = 'Zipcode',
				.fun = summarise,
				 minadi  =  min(dep_2000_90coeff_index),
				 maxadi  =  max(dep_2000_90coeff_index),
				 meanadi = mean(dep_2000_90coeff_index))

zipInfo <- read.csv('free-zipcode-database-Primary.csv')
zipInfo <- subset(zipInfo,ZipCodeType == 'STANDARD',select = c('Zipcode','City','State'))
zipInfo$Zipcode <- str_pad(zipInfo$Zipcode,5,side='left',pad='0')
zipInfo$City <- toTitleCase(tolower(as.character(zipInfo$City)))

adi.df <- join(adi.df,zipInfo)

##Save it
write.csv(adi.df,'adi_zip5_clean.csv')

