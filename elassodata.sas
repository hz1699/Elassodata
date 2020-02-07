/* In this program, I want to get the stocks prices for every 15 mins for stocks appear in the Lassoing HAR paper. */
options nosource nodate nocenter nonumber ps=max ls=72;

/*Define a macro that does the above for data of a particular year say 1993 */
%Macro elassodata (year =, outname =);
	/* First, define a couple macro variables. */
	%let taq_ds= &year: ;     * data set you are interested (example for all daily files on December 1995);
	%let start_time = '9:30:00't;    * starting time;
	%let interval_seconds =15*60;    * interval is 15*60 seconds (15 minutes);
	/* Then, we try to get the taq data for this particular year */
	data tempx;
     	set &taq_ds(keep=symbol date time price);
     	
     	where symbol in ('AA','C', 'HAS','INTC', 'MSFT', 'NKE', 'PFE', 'XOM') 
     	and
     	time between '9:30:00't and '16:30:00't;
     	by symbol date time;
     	retain itime rtime iprice; *Carry time and price values forward;
        	format itime rtime time12.;
     	if first.symbol=1 or first.date=1 then do;
        */Initialize time and price when new symbol or date starts;*/
        rtime=time;
        	iprice=price;
        	itime= &start_time;
     	end;
     	if time >= itime then do; /*Interval reached;*/
           output; /*rtime and iprice hold the last observation values;*/
           itime = itime + &interval_seconds;
           do while(time >= itime); /*need to fill in all time intervals;*/
               output;
               itime = itime + &interval_seconds;
           end;
    	end;
    	rtime=time;
    	iprice=price;
    	keep symbol date itime iprice rtime
	run;
	
	data &outname;
	set tempX;
	run;
%MEND elassodata;

%semicov2000(year =taq.ct_2013, outname = taq2013 );

proc export data=taq2013
   outfile="/scratch/duke/hz169/lasso2013.csv"
   dbms=dlm replace;
   delimiter=',';
 run;
