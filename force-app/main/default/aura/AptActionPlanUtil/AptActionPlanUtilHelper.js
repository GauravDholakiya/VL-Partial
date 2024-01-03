/**
 * @author Jozef 
 * @date 11.3.2019.
 * @description //TODO
 */
({

    getArgument: function(event, response){
        var params = event.getParam('arguments');
        var response;
        if (params) {
            response = params[response];
        }
        return response;
    },

    showError: function(aMessage){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Error',
            message: aMessage,
            key: 'info_alt',
            type: 'error',
            mode: 'sticky'
        });
        toastEvent.fire();
    },

   setNewStaticPeriods : function(apt){
       var statPer = this.getListOfStaticPeriods(apt);
       this.clearPeriods(apt, statPer);
   },

   getIniDateAccordingTemplatePlan: function(fiscalYear, apt, initDate){
        var iDate = initDate.initTaskDate;
        if (!$A.util.isEmpty(apt.ActionPlanTemplate__r)){
            if (apt.ActionPlanTemplate__r.Start_Date__c == 'Payroll_Date'){
                iDate = initDate.initPayrollDate;
            }else if(apt.ActionPlanTemplate__r.Start_Date__c == 'Reporting_Date') {
                iDate = initDate.initReportingDate;
            }else if(apt.ActionPlanTemplate__r.Start_Date__c == 'Reporting_Date_Plus') {
                iDate = this.addMonths(initDate.initReportingDate, 1);
            } else if (apt.ActionPlanTemplate__r.Start_Date__c == 'Reporting_Date_Plus_2') {
                iDate = this.addMonths(initDate.initReportingDate, 2);
            } else if (apt.ActionPlanTemplate__r.Start_Date__c == 'Fiscal_Year_End_Date_Plus_2') {
                //check if the date is by the end of month like 28 or 29 is the last day of the february month
                var newDate = new Date(initDate.initEndFiscalYear.getTime()),
                    getMonth = newDate.getMonth();
                newDate.setDate(newDate.getDate() + 1);
                var endOfMonth;
                if (newDate.getMonth() !== getMonth) {
                    endOfMonth = true;
                }
                if(endOfMonth==true){
                 var dateToPass = this.addMonths(initDate.initEndFiscalYear, 2, "Fiscal_Year_End_Date_Plus_2");
                 var lastDate = new Date(dateToPass.getFullYear(), dateToPass.getMonth() +1, 0).getDate();
                 iDate = new Date(dateToPass.getFullYear(), dateToPass.getMonth(), lastDate, 0, 0, 0, 0);;
                }else{
                 iDate = this.addMonths(initDate.initEndFiscalYear, 2, "Fiscal_Year_End_Date_Plus_2");
                }
            }
        }
        return iDate;
   },

   getIniDateAccordingTemplateTask: function(fiscalYear, apt, initDate){
       //console.log('getIniDateAccordingTemplateTask ' + apt.APT_Task__r.Initial_Start_Date__c);
       var iDate = initDate.initTaskDate;
       if (apt.APT_Task__r.Initial_Start_Date__c == 'Payroll Date'){
           iDate = initDate.initPayrollDate;
       }else if(apt.APT_Task__r.Initial_Start_Date__c == 'Reporting Date') {
           iDate = initDate.initReportingDate;
       } else if (apt.APT_Task__r.Initial_Start_Date__c == 'Fiscal Year end date') {
           iDate = initDate.initEndFiscalYear;
       } else if (apt.APT_Task__r.Initial_Start_Date__c == 'Year end reporting date') {
           iDate = initDate.initYearEndReportingDate;
       } else if (apt.APT_Task__r.Initial_Start_Date__c  == 'Closing date') {
           iDate = initDate.initCloseDate;
       }
       return iDate;
   },

   getIniDate : function(fiscalYear, apt, initDate){
        let iDate;
        if (!$A.util.isEmpty(apt.APT_Task__c) && !$A.util.isEmpty(apt.APT_Task__r.Initial_Start_Date__c)){
            iDate = this.getIniDateAccordingTemplateTask(fiscalYear, apt, initDate);
        }else{
            iDate = this.getIniDateAccordingTemplatePlan(fiscalYear, apt, initDate);
        }
        return iDate;
   },

   setNewPeriods : function(fiscalYear, apt, initDate){
        let iDate = this.getIniDate(fiscalYear, apt, initDate);
        this.setNewStaticPeriods(apt);
        this.setPeriodsByFrequency(fiscalYear, apt, iDate);
        this.clearStaticPeriods(apt);
   },

   setPeriodsByFrequency : function(fiscalYear, apt, initDate){
      //console.log('setPeriodsByFrequency');
      var yearDiffObj = this.getDiffYear(apt, fiscalYear);
      var diffYear = yearDiffObj.diffYear;
      if (apt.Frequency__c == 'Monthly' || apt.Frequency__c == 'Månedlig'){
          this.setMonthly(diffYear, initDate, apt);
      }else if (apt.Frequency__c == 'Bi-monthly' || apt.Frequency__c == 'Terminvis'){
          this.setBiMonthly(diffYear, initDate, apt);
      }else if (apt.Frequency__c == 'Quarterly' || apt.Frequency__c == 'Kvartalsvis'){
          this.setQuarterly(diffYear, initDate, apt);
      }else if (apt.Frequency__c == 'Interim' || apt.Frequency__c == 'Tertial'){
          this.setInterim(diffYear, initDate, apt);
      }else if (apt.Frequency__c == 'Biannual' || apt.Frequency__c == 'Halvårlig'){
          this.setBiannual(diffYear, initDate, apt);
      }else if (apt.Frequency__c == 'Annual' || apt.Frequency__c == 'Årlig'){
          this.setAnnual(diffYear, initDate, apt);
      }
      if(!$A.util.isEmpty(apt.Frequency__c)){

        //('apt--1>'+JSON.stringify(apt));
        //console.log('setPeriodsByFrequency Function--1>'+apt.Frequency__c);
        //console.log('fiscalYear--1>'+fiscalYear);
        //console.log('initDate--1>'+initDate);
        //console.log('diffYear--1>'+diffYear);
        this.setPeriod12(diffYear, initDate, apt, fiscalYear, yearDiffObj.period);
      }
   },


   setPeriods : function(fiscalYear, apt, initDate){
       let iDate = this.getIniDate(fiscalYear, apt, initDate);
       this.clearNotCompletedPeriods(apt);
       this.setPeriodsByFrequency(fiscalYear, apt, iDate);
   },


   getDiffYear: function(apt, fiscalYear){
       var yearDiffObj = {};
       yearDiffObj.diffYear = 0;
       yearDiffObj.period = 0;
       var fy = parseInt(fiscalYear);
       var listAll = ['1','2','3','4','5','6','7','8','9','10','11','12'];
       for (var i = 0; i < listAll.length; i++) {
            var period = listAll[i];
            var staticAttribute = this.getStaticPeriodField(period);
            var periodField = this.getPeriodField(period);
            //console.log(apt[periodField]);
            if (apt[staticAttribute] == true && !$A.util.isEmpty(apt[periodField])){
                 //console.log(apt[periodFields]);
                 var dt = new Date(apt[periodField]);
                 var currentYear = dt.getFullYear();
                 //console.log(currentYear);
                 yearDiffObj.diffYear = fy - currentYear;
                 yearDiffObj.period = i;
                 break;
            }
       }
       //console.log(diffYear);
       return yearDiffObj;
   },


   /* -- Original Code - Commented by Sushant Friday 27 May 2022
   // Incident Handling - 

   addMonths: function(dt, n){
         var month = dt.getMonth() + n;
         var dateInst = new Date(dt.getFullYear(), month, dt.getDate(), 0, 0, 0, 0);
         // console.log('dateInst-->'+dateInst);
         return dateInst;
     },
   */
     addMonths: function(dt, n, taskStartDate){
         // console.log('dt-->'+dt);
         // console.log('dt.getMonth-->'+dt.getMonth());
         var dateInst ;
         if(taskStartDate !== "Fiscal_Year_End_Date_Plus_2" && (taskStartDate === "" || taskStartDate === undefined )){
             //console.log("iffffff");
             var d = dt.getDate();
            var month = dt.getMonth() + n;
            var dateInst = new Date(dt.getFullYear(), month, dt.getDate(), 0, 0, 0, 0);
            if(dateInst.getDate() != d){
                dateInst.setDate(0);
           }
            // console.log('dateInst-1->'+dateInst);
         }else{
            // console.log("elseeeee");
            var d = dt.getDate();
            dateInst = new Date(dt.getFullYear(), dt.getMonth(), dt.getDate(), 0, 0, 0, 0);
            dateInst.setMonth(dateInst.getMonth() + +n);
            // console.log('dateInst-2->'+dateInst);
            if(dateInst.getDate() != d){
                 dateInst.setDate(0);
            }
         }
         

         return dateInst;
     },

     addMonthsFormat: function(dt, n){
          return this.formatDate(this.addMonths(dt, n));
     },

     // Commented by Sushant Friday 27 May 2022
     // Incident Handling - 
     getMonth: function(stringDate){
          var dt = new Date(stringDate);
          return dt.getMonth();
     },

      changeYear: function(stringDate, diffYear){
          if ($A.util.isEmpty(stringDate)) return '';
          var dt = new Date(stringDate);
          var currentYear = dt.getFullYear();
          var dateInst = new Date(currentYear + diffYear, dt.getMonth(), dt.getDate(), 0, 0, 0, 0);
           //console.log(dateInst);
          return this.formatDate(dateInst);
      },

      changeYearForAnnual: function(stringDate, fiscalYear){
           if ($A.util.isEmpty(stringDate)) return '';
           var dt = new Date(stringDate);
           var dateInst = new Date(parseInt(fiscalYear), dt.getMonth(), dt.getDate(), 0, 0, 0, 0);
           return this.formatDate(dateInst);
      },

      setPeriod12: function(diffYear, initDate, apt, fiscalYear, period){
        //if diffYear == 0
        //if iniDate month == january AND Period12 == December
        //=> fiscaly year
        //else fiscaly year + 1
        
          if (apt.P12static == false){


              //Commented by Sushant Friday 27 May 2022
              // Incident Handling - 
               //apt.Period_12__c = this.addMonthsFormat(initDate, 11);
               if(apt.ActionPlanTemplate__r.Start_Date__c == 'Fiscal_Year_End_Date_Plus_2'){
                    apt.Period_12__c = this.addMonthsFormat(initDate, 0);
               }else{
                    apt.Period_12__c = this.addMonthsFormat(initDate, 11);
               }
          }else{
              //console.log('period ' + period);
              if (period != 11){
                  apt.Period_12__c =  this.changeYear(apt.Period_12__c, diffYear);
              }else{
                  if ($A.util.isEmpty(apt.Period_12__c)){
                      apt.Period_12__c = '';
                  }else{
                      var month = initDate.getMonth();
                      //console.log('month ' + month);
                      //console.log(this.getMonth(apt.Period_12__c));
                      if (month == 0 && this.getMonth(apt.Period_12__c) == 11 ){
                          apt.Period_12__c =  this.changeYearForAnnual(apt.Period_12__c, fiscalYear);
                      }else{
                          apt.Period_12__c =  this.changeYear(apt.Period_12__c, diffYear + 1);
                      }
                  }
              }
          }
      },

      setAnnual: function(diffYear, initDate, apt){
          if (apt.P1static == true){
              apt.Period_1__c =  this.changeYear(apt.Period_1__c, diffYear);
          }
          if (apt.P2static == true){
              apt.Period_2__c =  this.changeYear(apt.Period_2__c, diffYear);
          }
          if (apt.P3static == true){
              apt.Period_3__c =  this.changeYear(apt.Period_3__c, diffYear);
          }
          if (apt.P4static == true){
              apt.Period_4__c =  this.changeYear(apt.Period_4__c, diffYear);
          }
          if (apt.P5static == true){
              apt.Period_5__c =  this.changeYear(apt.Period_5__c, diffYear);
          }
          if (apt.P6static == true){
              apt.Period_6__c =  this.changeYear(apt.Period_6__c, diffYear);
          }
          if (apt.P7static == true){
              apt.Period_7__c =  this.changeYear(apt.Period_7__c, diffYear);
          }
          if (apt.P8static == true){
              apt.Period_8__c =  this.changeYear(apt.Period_8__c, diffYear);
          }
          if (apt.P9static == true){
              apt.Period_9__c =  this.changeYear(apt.Period_9__c, diffYear);
          }
          if (apt.P10static == true){
              apt.Period_10__c =  this.changeYear(apt.Period_10__c, diffYear);
          }
          if (apt.P11static == true){
              apt.Period_11__c =  this.changeYear(apt.Period_11__c, diffYear);
          }

      },

      setBiannual: function(diffYear, initDate, apt){
              if (apt.P1static == true){
                  apt.Period_1__c =  this.changeYear(apt.Period_1__c, diffYear);
              }
              if (apt.P2static == true){
                  apt.Period_2__c =  this.changeYear(apt.Period_2__c, diffYear);
              }
              if (apt.P3static == true){
                  apt.Period_3__c =  this.changeYear(apt.Period_3__c, diffYear);
              }
              if (apt.P4static == true){
                  apt.Period_4__c =  this.changeYear(apt.Period_4__c, diffYear);
              }
              if (apt.P5static == true){
                  apt.Period_5__c =  this.changeYear(apt.Period_5__c, diffYear);
              }
              if (apt.P7static == true){
                  apt.Period_7__c =  this.changeYear(apt.Period_7__c, diffYear);
              }
              if (apt.P8static == true){
                  apt.Period_8__c =  this.changeYear(apt.Period_8__c, diffYear);
              }
              if (apt.P9static == true){
                  apt.Period_9__c =  this.changeYear(apt.Period_9__c, diffYear);
              }
              if (apt.P10static == true){
                  apt.Period_10__c =  this.changeYear(apt.Period_10__c, diffYear);
              }
              if (apt.P11static == true){
                  apt.Period_11__c =  this.changeYear(apt.Period_11__c, diffYear);
              }

            if (apt.P6static == false){
                 apt.Period_6__c = this.addMonthsFormat(initDate, 5);
            }else{
                 apt.Period_6__c =  this.changeYear(apt.Period_6__c, diffYear);
            }
            /*
            if (apt.P12static == false){
                apt.Period_12__c = this.addMonthsFormat(initDate, 11);
            }else{
                apt.Period_12__c =  this.changeYear(apt.Period_12__c, diffYear);
            }
            */
      },

      clearNotCompletedPeriods: function(apt){
         if (apt.P1static == false){
             apt.Period_1__c =  null;
         }
         if (apt.P2static == false){
             apt.Period_2__c =  null;
         }
         if (apt.P3static == false){
             apt.Period_3__c =  null;
         }
         if (apt.P4static == false){
             apt.Period_4__c =  null;
         }
         if (apt.P5static == false){
             apt.Period_5__c =  null;
         }
         if (apt.P6static == false){
             apt.Period_6__c =  null;
         }
         if (apt.P7static == false){
             apt.Period_7__c =  null;
         }
         if (apt.P8static == false){
             apt.Period_8__c =  null;
         }
         if (apt.P9static == false){
             apt.Period_9__c =  null;
         }
         if (apt.P10static == false){
             apt.Period_10__c =  null;
         }
         if (apt.P11static == false){
             apt.Period_11__c =  null;
         }
         if (apt.P12static == false){
             apt.Period_12__c =  null;
         }
      },

      clearPeriods: function(apt, statPer){
           if (!statPer.includes('1')){
               apt.Period_1__c =  null;
               apt.P1static = false;
           }else{
               apt.P1static = true;
           }
           if (!statPer.includes('2')){
               apt.Period_2__c =  null;
               apt.P2static = false;
           }else{
               apt.P2static = true;
           }
           if (!statPer.includes('3')){
               apt.Period_3__c = null;
               apt.P3static = false;
           }else{
               apt.P3static = true;
           }
           if (!statPer.includes('4')){
               apt.Period_4__c =  null;
               apt.P4static = false;
           }else{
               apt.P4static = true;
           }
           if (!statPer.includes('5')){
               apt.Period_5__c = null;
               apt.P5static = false;
           }else{
               apt.P5static = true;
           }
           if (!statPer.includes('6')){
               apt.Period_6__c = null;
               apt.P6static = false;
           }else{
               apt.P6static = true;
           }
           if (!statPer.includes('7')){
               apt.Period_7__c = null;
               apt.P7static = false;
           }else{
               apt.P7static = true;
           }
           if (!statPer.includes('8')){
               apt.Period_8__c =  null;
               apt.P8static = false;
           }else{
               apt.P8static = true;
           }
           if (!statPer.includes('9')){
               apt.Period_9__c =  null;
               apt.P9static = false;
           }else{
               apt.P9static = true;
           }
           if (!statPer.includes('10')){
               apt.Period_10__c =  null;
               apt.P10static = false;
           }else{
               apt.P10static = true;
           }
           if (!statPer.includes('11')){
               apt.Period_11__c =  null;
               apt.P11static = false;
           }else {
               apt.P11static = true;
           }
           if (!statPer.includes('12')){
              apt.Period_12__c =  null;
              apt.P12static = false;
           }else {
              apt.P12static = true;
           }
      },

      clearStaticPeriods: function(apt){
         apt.P1static = false;
         apt.P2static = false;
         apt.P3static = false;
         apt.P4static = false;
         apt.P5static = false;
         apt.P6static = false;
         apt.P7static = false;
         apt.P8static = false;
         apt.P9static = false;
         apt.P10static = false;
         apt.P11static = false;
         apt.P12static = false;
      },

      setStaticPeriods : function(apt){
          var statPer = this.getListOfStaticPeriods(apt);
          var listAll = ['1','2','3','4','5','6','7','8','9','10','11','12'];
          for (var i = 0; i < listAll.length; i++) {
              var period = listAll[i];
              var periodAttribute = this.getStaticPeriodField(period);
              if (!statPer.includes(period)){
                 apt[periodAttribute] = false;
              }else {
                 apt[periodAttribute] = true;
              }
          }
      },

      setInterim: function(diffYear, initDate, apt){
              if (apt.P1static == true){
                  apt.Period_1__c =  this.changeYear(apt.Period_1__c, diffYear);
              }
              if (apt.P2static == true){
                  apt.Period_2__c =  this.changeYear(apt.Period_2__c, diffYear);
              }
              if (apt.P3static == true){
                  apt.Period_3__c =  this.changeYear(apt.Period_3__c, diffYear);
              }
              if (apt.P5static == true){
                  apt.Period_5__c =  this.changeYear(apt.Period_5__c, diffYear);
              }
              if (apt.P6static == true){
                  apt.Period_6__c =  this.changeYear(apt.Period_6__c, diffYear);
              }
              if (apt.P7static == true){
                  apt.Period_7__c =  this.changeYear(apt.Period_7__c, diffYear);
              }
              if (apt.P9static == true){
                  apt.Period_9__c =  this.changeYear(apt.Period_9__c, diffYear);
              }
              if (apt.P10static == true){
                  apt.Period_10__c =  this.changeYear(apt.Period_10__c, diffYear);
              }
              if (apt.P11static == true){
                  apt.Period_11__c =  this.changeYear(apt.Period_11__c, diffYear);
              }

            if (apt.P4static == false){
                 apt.Period_4__c = this.addMonthsFormat(initDate, 3);
            }else{
                 apt.Period_4__c =  this.changeYear(apt.Period_4__c, diffYear);
            }
            if (apt.P8static == false){
                apt.Period_8__c = this.addMonthsFormat(initDate, 7);
            }else{
                apt.Period_8__c =  this.changeYear(apt.Period_8__c, diffYear);
            }
            /*
            if (apt.P12static == false){
                apt.Period_12__c = this.addMonthsFormat(initDate, 11);
            }else{
                apt.Period_12__c =  this.changeYear(apt.Period_12__c, diffYear);
            }*/

     },

     setQuarterly: function(diffYear, initDate, apt){
        if (apt.P1static == true){
            apt.Period_1__c =  this.changeYear(apt.Period_1__c, diffYear);
        }
        if (apt.P2static == true){
            apt.Period_2__c =  this.changeYear(apt.Period_2__c, diffYear);
        }
        if (apt.P4static == true){
            apt.Period_4__c =  this.changeYear(apt.Period_4__c, diffYear);
        }
        if (apt.P5static == true){
            apt.Period_5__c =  this.changeYear(apt.Period_5__c, diffYear);
        }
        if (apt.P7static == true){
            apt.Period_7__c =  this.changeYear(apt.Period_7__c, diffYear);
        }
        if (apt.P8static == true){
            apt.Period_8__c =  this.changeYear(apt.Period_8__c, diffYear);
        }
        if (apt.P10static == true){
            apt.Period_10__c =  this.changeYear(apt.Period_10__c, diffYear);
        }
        if (apt.P11static == true){
            apt.Period_11__c =  this.changeYear(apt.Period_11__c, diffYear);
        }
        if (apt.P3static == false){
             apt.Period_3__c = this.addMonthsFormat(initDate, 2);
        }else{
             apt.Period_3__c =  this.changeYear(apt.Period_3__c, diffYear);
        }
        if (apt.P6static == false){
            apt.Period_6__c = this.addMonthsFormat(initDate, 5);
        }else{
            apt.Period_6__c =  this.changeYear(apt.Period_6__c, diffYear);
        }
        if (apt.P9static == false){
            apt.Period_9__c = this.addMonthsFormat(initDate, 8);
        }else{
            apt.Period_9__c =  this.changeYear(apt.Period_9__c, diffYear);
        }
        /*
        if (apt.P12static == false){
            apt.Period_12__c = this.addMonthsFormat(initDate, 11);
        }else{
            apt.Period_12__c =  this.changeYear(apt.Period_12__c, diffYear);
        }
        */
     },

     setBiMonthly: function(diffYear, initDate, apt){
        if (apt.P1static == true){
            apt.Period_1__c =  this.changeYear(apt.Period_1__c, diffYear);
        }
        if (apt.P2static == false){
            apt.Period_2__c = this.addMonthsFormat(initDate, 1);
        }else{
            apt.Period_2__c =  this.changeYear(apt.Period_2__c, diffYear);
        }
        if (apt.P3static == true){
            apt.Period_3__c =  this.changeYear(apt.Period_3__c, diffYear);
        }
        if (apt.P4static == false){
            apt.Period_4__c = this.addMonthsFormat(initDate, 3);
        }else{
            apt.Period_4__c =  this.changeYear(apt.Period_4__c, diffYear);
        }
        if (apt.P5static == true){
            apt.Period_5__c =  this.changeYear(apt.Period_5__c, diffYear);
        }
        if (apt.P6static == false){
            apt.Period_6__c = this.addMonthsFormat(initDate, 5);
        }else{
            apt.Period_6__c =  this.changeYear(apt.Period_6__c, diffYear);
        }
        if (apt.P7static == true){
            apt.Period_7__c =  this.changeYear(apt.Period_8__c, diffYear);
        }
        if (apt.P8static == false){
            apt.Period_8__c = this.addMonthsFormat(initDate, 7);
        }else{
            apt.Period_8__c =  this.changeYear(apt.Period_8__c, diffYear);
        }
        if (apt.P9static == true){
            apt.Period_9__c =  this.changeYear(apt.Period_9__c, diffYear);
        }
        if (apt.P10static == false){
            apt.Period_10__c = this.addMonthsFormat(initDate, 9);
        }else{
            apt.Period_10__c =  this.changeYear(apt.Period_10__c, diffYear);
        }
        if (apt.P11static == true){
            apt.Period_11__c =  this.changeYear(apt.Period_11__c, diffYear);
        }
        /*
        if (apt.P12static == false){
            apt.Period_12__c = this.addMonthsFormat(initDate, 11);
        }else{
            apt.Period_12__c =  this.changeYear(apt.Period_12__c, diffYear);
        }*/
     },

     getListOfStaticPeriods : function(apt){
         var statperoids = [];
         if (!$A.util.isEmpty(apt.TemplateStaticPeriods__c)){
             statperoids = apt.TemplateStaticPeriods__c.split(';');
         }
         return statperoids;
     },

     setMonthly: function(diffYear, initDate, apt){
         //initDate same day, same month, same year
         if (apt.P1static == false){
            apt.Period_1__c = this.formatDate(initDate);
         }else{
            apt.Period_1__c =  this.changeYear(apt.Period_1__c, diffYear);
         }
         if (apt.P2static == false){
            apt.Period_2__c = this.addMonthsFormat(initDate, 1);
         }else{
            apt.Period_2__c =  this.changeYear(apt.Period_2__c, diffYear);
         }
         if (apt.P3static == false){
            apt.Period_3__c = this.addMonthsFormat(initDate, 2);
         }else{
            apt.Period_3__c =  this.changeYear(apt.Period_3__c, diffYear);
         }
         if (apt.P4static == false){
            apt.Period_4__c = this.addMonthsFormat(initDate, 3);
         }else{
            apt.Period_4__c =  this.changeYear(apt.Period_4__c, diffYear);
         }
         if (apt.P5static == false){
            apt.Period_5__c = this.addMonthsFormat(initDate, 4);
         }else{
            apt.Period_5__c =  this.changeYear(apt.Period_5__c, diffYear);
         }
         if (apt.P6static == false){
            apt.Period_6__c = this.addMonthsFormat(initDate, 5);
         }else{
            apt.Period_6__c =  this.changeYear(apt.Period_6__c, diffYear);
         }
         if (apt.P7static == false){
            apt.Period_7__c = this.addMonthsFormat(initDate, 6);
         }else{
            apt.Period_7__c =  this.changeYear(apt.Period_7__c, diffYear);
         }
         if (apt.P8static == false){
            apt.Period_8__c = this.addMonthsFormat(initDate, 7);
         }else{
            apt.Period_8__c =  this.changeYear(apt.Period_8__c, diffYear);
         }
         if (apt.P9static == false){
            apt.Period_9__c = this.addMonthsFormat(initDate, 8);
         }else{
            apt.Period_9__c =  this.changeYear(apt.Period_9__c, diffYear);
         }
         if (apt.P10static == false){
            apt.Period_10__c = this.addMonthsFormat(initDate, 9);
         }else{
            apt.Period_10__c =  this.changeYear(apt.Period_10__c, diffYear);
         }
         if (apt.P11static == false){
            apt.Period_11__c = this.addMonthsFormat(initDate, 10);
         }else{
            apt.Period_11__c =  this.changeYear(apt.Period_11__c, diffYear);
         }
         /*
         if (apt.P12static == false){
            apt.Period_12__c = this.addMonthsFormat(initDate, 11);
         }else{
            apt.Period_12__c =  this.changeYear(apt.Period_12__c, diffYear);
         }*/
     },

   formatDate: function(date) {
        var d = new Date(date),
            month = '' + (d.getMonth() + 1),
            day = '' + d.getDate(),
            year = d.getFullYear();

        if (month.length < 2) month = '0' + month;
        if (day.length < 2) day = '0' + day;

        return [year, month, day].join('-');
   },

   filterByKeyword: function(searchKey, tasks) {
        if(!$A.util.isEmpty(searchKey)){
          searchKey = searchKey.toUpperCase();
        }
        if(!$A.util.isEmpty(tasks)){
          for (var i = 0; i < tasks.length; i++) {
              var task = tasks[i];
              task.IsVisible__c = false;
              if(!$A.util.isEmpty(task.Subject__c)){
                  if (task.Subject__c.toUpperCase().includes(searchKey)){
                      task.IsVisible__c = true;
                  }
              }
              if(!$A.util.isEmpty(task.Task_Number__c)){
                  if (task.Task_Number__c.toString().includes(searchKey)){
                      task.IsVisible__c = true;
                  }
              }
              if(!$A.util.isEmpty(task.User__c)){
                  if (task.User__r.Name.toUpperCase().includes(searchKey)){
                      task.IsVisible__c = true;
                  }
              }
              if(!$A.util.isEmpty(task.ActionPlanTemplate__c)){
                  if (task.ActionPlanTemplate__r.Name.toUpperCase().includes(searchKey)){
                      task.IsVisible__c = true;
                  }
              }
          }
        }
        return tasks;
   },

   findByNameAndNumber: function(searchKey, tasks) {
        if(!$A.util.isEmpty(searchKey)){
            searchKey = searchKey.toUpperCase();
        }
        if(!$A.util.isEmpty(tasks)){
            for (var i = 0; i < tasks.length; i++) {
                var task = tasks[i];
                task.IsVisible__c = false;
                if(!$A.util.isEmpty(task.Subject__c)){
                    if (task.Subject__c.toUpperCase().includes(searchKey)){
                        task.IsVisible__c = true;
                    }
                }
                if(!$A.util.isEmpty(task.Task_Number__c)){
                    if (task.Task_Number__c.toString().includes(searchKey)){
                        task.IsVisible__c = true;
                    }
                }
            }
        }
        return tasks;
   },

   datediff: function(first, second) {
        // Take the difference between the dates and divide by milliseconds per day.
        // Round to nearest whole number to deal with DST.
        return Math.round((second-first)/(1000*60*60*24));
   },

   addDaysFormat: function(dt, n){
      var day = dt.getDate() + n;
      var dateInst = new Date(dt.getFullYear(), dt.getMonth(), day, 0, 0, 0, 0);
      //console.log(dateInst);
      return this.formatDate(dateInst);
   },

    getDateWithSkipWeekendFeature: function(periodDate) {
       //console.log('<--' + periodDate);
       if(!$A.util.isEmpty(periodDate)){
           var pDate = new Date(periodDate);
           var monday = new Date(1900, 0, 1 , 0, 0, 0, 0);
           var dayDiff = this.datediff(monday, pDate);
           var modulo = dayDiff % 7;
           ///modulo 5 - Saturday, 6 - Sunday
           if( modulo == 5 || modulo == 6 ) {
               var shiftD = 4 - modulo;
               periodDate = this.addDaysFormat(pDate, shiftD);
           }
       }
       //console.log('-->' + periodDate);
       return periodDate;
    },

    skipWeekend: function(apt, skip) {
        //console.log(apt.Subject__c + ' skipWeekend: ' + apt.Period_1__c);
        //console.log(apt);
        var listAll = ['1','2','3','4','5','6','7','8','9','10','11','12'];
        if (skip == true){
            for (var i = 0; i < listAll.length; i++) {
                 var period = listAll[i];
                 var periodAttribute = this.getStaticPeriodField(period);
                 //console.log(apt[periodAttribute]);
                 //console.log($A.util.isEmpty(apt[periodAttribute]));
                 if (apt[periodAttribute] == false || !apt.hasOwnProperty(periodAttribute)){
                    var pField = this.getPeriodField(period);
                    var originField = this.getOriginPeriodField(period);
                    apt[originField] = apt[pField];
                    apt[pField] = this.getDateWithSkipWeekendFeature(apt[pField]);
                 }
            }
        } else {
            for (var i = 0; i < listAll.length; i++) {
                 var period = listAll[i];
                 var periodAttribute = this.getStaticPeriodField(period);
                 if (apt[periodAttribute] == false || !apt.hasOwnProperty(periodAttribute)){
                     var pField = this.getPeriodField(period);
                     var originField = this.getOriginPeriodField(period);
                     var originValue = apt[originField];
                     if (!$A.util.isEmpty(originValue)){
                        apt[pField] = originValue;
                     }
                 }
            }
        }
    },

    getStaticPeriodField:  function(period){
        return 'P'+period+'static';
    },

    getOriginPeriodField:  function(period){
        return 'P'+period+'origin';
    },

    getPeriodField:  function(period){
        return 'Period_' + period + '__c';
    },

})