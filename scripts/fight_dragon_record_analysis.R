df <- read.csv("/Users/daili/Desktop/personal/mud/xyj/logs/fight_dragon_rewards_hotfish.txt",sep = '\t',header= FALSE,
         col.names = c('ts','data'), colClasses = c('POSIXct','character'))

df$time_1min <- as.POSIXct(floor(as.numeric(df$ts)/(60))*(60), origin = strptime("1970-01-01", "%Y-%m-%d", tz=""))
df$time_5mins <- as.POSIXct(floor(as.numeric(df$ts)/(5*60))*(5*60), origin = strptime("1970-01-01", "%Y-%m-%d", tz=""))
df$time_15mins <- as.POSIXct(floor(as.numeric(df$ts)/(15*60))*(15*60), origin = strptime("1970-01-01", "%Y-%m-%d", tz=""))
df$time_1hr <- as.POSIXct(floor(as.numeric(df$ts)/(60*60))*(60*60), origin = strptime("1970-01-01", "%Y-%m-%d", tz=""))

number_indecies <- as.numeric(df$data) > 0
df_events <- df[is.na(number_indecies),]

df <-  df[!is.na(number_indecies),]
names(df)[2] <- 'wx_increase'
df$wx_increase <- as.numeric(df[,2])

par(mfrow = c(3, 1), mex=0.6, mar=c(5,5,2,2))

#1h plot
df_plot <- aggregate(wx_increase ~ time_1hr, data = df, FUN = sum)
colnames(df_plot)[1] <- 'time'
lower <- max(df$ts) - 60*60*24
upper <- max(df$ts)
df_plot <- df_plot[df_plot$time >= lower & df_plot$time <= upper,]
plot(df_plot, type = 'b', col = 'blue', xlim = c( lower, upper), 
     ylim = c(0.8*min(df_plot$wx_increase), 1.2*max(df_plot$wx_increase)),
     xlab = '', ylab = '', main = 'Per hour gain in past 24 hour')
abline(v = df_events$ts, col = 'red')
text(x = lower, y = 0.8*max(df_plot$wx_increase) + 0.2*min(df_plot$wx_increase), 
     paste("Acquired ", sum(df_plot$wx_increase) ,"wx in past 24 hours"), 
     pos = 4, cex = 1.2, col = 'purple')


#5 minutes plo
df_plot <- aggregate(wx_increase ~ time_5mins, data = df, FUN = sum)
colnames(df_plot)[1] <- 'time'
lower <- max(df$ts) - 60*60
upper <- max(df$ts)
df_plot <- df_plot[df_plot$time >= lower & df_plot$time <= upper,]
df_plot <- df_plot[1: (dim(df_plot)[1]-1),]
plot(df_plot, type = 'b', col = 'blue', xlim = c( lower, upper), 
     ylim = c(0.8*min(df_plot$wx_increase), 1.2*max(df_plot$wx_increase)),
     xlab = '', ylab = '', main = 'Per 5 minutes gain in past hour')
abline(v = df_events$ts, col = 'red')
text(x = lower, y = 0.8*max(df_plot$wx_increase) + 0.2*min(df_plot$wx_increase), 
     paste("Expecting ", round(mean(df_plot$wx_increase)*24*12) ,"wx/day\n",
          "On average ", round(mean(df_plot$wx_increase)),"wx/5mins"), 
     pos = 4, cex = 1.2, col = 'purple')

#1 minute plot
df_plot <- aggregate(wx_increase ~ time_1min, data = df, FUN = sum)
colnames(df_plot)[1] <- 'time'
lower <- max(df$ts) - 60*15
upper <- max(df$ts)
df_plot <- df_plot[df_plot$time >= lower & df_plot$time <= upper,]
df_plot <- df_plot[1: (dim(df_plot)[1]-1),]
plot(df_plot, type = 'b', col = 'blue', xlim = c( lower, upper), 
     ylim = c(0.8*min(df_plot$wx_increase), 1.2*max(df_plot$wx_increase)),
     xlab = '', ylab = '', main = 'Per minute gain in past 15 minutes')
abline(v = df_events$ts, col = 'red')
text(x = lower, y = 1*max(df_plot$wx_increase) + 0*min(df_plot$wx_increase), 
     paste("Expecting ", round(mean(df_plot$wx_increase)*24*60) ,"wx /day\n",
           "On average ", round(mean(df_plot$wx_increase),1),"wx /min"), 
     pos = 4, cex = 1.2, col = 'purple')
