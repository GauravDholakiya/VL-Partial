({
	resetNewRecord: function (component) {
		let newRecord    = {
			'Time_Type__c': '0 Normal Time',
			'Registered_Hours__c': 0,
			'Registered_Minutes__c': 0,
			'Billable_Hours__c': 0,
			'Billable_Minutes__c': 0,
			'Project_Country__c' : '--None--',
			'Main_Price_Agreement__c' : '',
			'Activity_Price_Agreement__c' : 'Hourly Rate',
			'Units__c' : 0
		};

		component.set("v.newRecord", newRecord);
        component.set("v.commentRequired", false);
		component.set("v.newRecordRegisteredHours", 0);
		component.set("v.newRecordRegisteredMinutes", 0);
		component.set("v.newRecordBillableHours", 0);
		component.set("v.newRecordBillableMinutes", 0);
		component.set("v.minutesPerDay", 0);
		component.set("v.hoursPerDay", 0);
		component.set("v.newRecordBillableMinutes", 0);
		//Time Type remove
		component.set("v.timeTypeOptions", component.get("v.publicTimeTypeOptions"));
		this.disableTimeType(component, false);
	},

	loadProjectTasks: function (component) {
		console.log("Start loadProjectTasks");	

		var nameFilterString = component.get("v.searchKey");
		var internalFilter = component.get("v.internalFilter");
		var operationalFilter = component.get("v.operationalFilter");
		//var regisDate = component.get("v.regDate");
		console.log("Searchkey: " + nameFilterString);
		console.log("internalFilter: " + internalFilter);
        console.log("operationalFilter: " + operationalFilter);

		var action = component.get("c.getProjTasks");
		action.setParams({
			"nameFilterString": nameFilterString,
			"internalFilter" : internalFilter,
			"operationalFilter" : operationalFilter
		});

		action.setCallback(this, function (a) {
			var state = a.getState();
			if (state === "SUCCESS") {
				console.log("## Loaded Project Tasks");
				console.dir(a.getReturnValue());
				var projectTasks = a.getReturnValue();
				for (var i = 0; i < projectTasks.length; i++) {
					if (projectTasks[i].Project__r == undefined) {
						projectTasks[i].Project__r = {Account__r:{}};
					}
					if (projectTasks[i].Project__r.Account__r == undefined) {
						projectTasks[i].Project__r.Account__r = {Reason_For_Deactivation__c:"", Deactivated__c:false};
					}
					if (projectTasks[i].Project__r.Account__r.Reason_For_Deactivation__c == undefined) {
						projectTasks[i].Project__r.Account__r.Reason_For_Deactivation__c = "";
					}
					if (projectTasks[i].Project__r.Account__r.Deactivated__c == undefined) {
						projectTasks[i].Project__r.Account__r.Deactivated__c = false;
					}
					if (projectTasks[i].Project__r.Account__r.Termination_end_date__c == undefined) {
						projectTasks[i].Project__r.Account__r.Termination_end_date__c = "";
					}
					if (projectTasks[i].Project__r.Account__r.Late_payment__c == undefined) {
						projectTasks[i].Project__r.Account__r.Late_payment__c = false;
					}
					if (projectTasks[i].Default_Time_Type__c == undefined) {
						projectTasks[i].Default_Time_Type__c = component.get("v.TimeTypeDefaultValue");
					}
					if (projectTasks[i].Lock_Time_Type__c == undefined) {
						projectTasks[i].Lock_Time_Type__c = false;
					}
					var currentdate = new Date();
					var terminationDate = (projectTasks[i].Project__r.Account__r.Termination_end_date__c==""?null:new Date(parseInt(projectTasks[i].Project__r.Account__r.Termination_end_date__c.substring(0,4)),parseInt(projectTasks[i].Project__r.Account__r.Termination_end_date__c.substring(5,7))-1,parseInt(projectTasks[i].Project__r.Account__r.Termination_end_date__c.substring(8,11))));
					if ((projectTasks[i].Project__r.Account__r.Termination_end_date__c != "" && terminationDate > currentdate) || 
					    (projectTasks[i].Project__r.Account__r.Late_payment__c && projectTasks[i].Project__r.Account__r.Termination_end_date__c == "")) {
						projectTasks[i].AccountStatus = "yellow";
					} else if (projectTasks[i].Project__r.Account__r.Termination_end_date__c != "" && terminationDate < currentdate) {
						projectTasks[i].AccountStatus = "red";
					} else {
						projectTasks[i].AccountStatus = "green";
					}
				}
				component.set("v.projectTasks", projectTasks);
				component.set("v.isSearching", false);
				console.log("## Body:");
				console.dir(component.get("v.body"));				

				// Remove the old list
				component.set("v.body", []);

				$A.createComponent(
					"c:ProjectTaskList",
					{
						"aura:id": "ProjectTaskList",
						"projectTaskList": projectTasks
					},
					function (newCmp, status, errorMessage) {
						if (status === "SUCCESS") {
							console.log("Component created.");
							var body = component.get("v.body");
							body.push(newCmp);
							component.set("v.body", body);
						}
						else if (status === "ERROR") {
							console.log("Error: " + errorMessage);
						}
					}
				);
			} else if (state === "ERROR") {
				//Actions for error
				console.log("Error retreiving Project Tasks.");
				component.set("v.issearching", false);
			} else {
				//Another stuff
				console.log("Unknown Error retreiving Project Tasks.");
				component.set("v.issearching", false);
			}
		});

		$A.enqueueAction(action);
	},
	showWarningMessage : function(component) {
		var projectTasks = component.get("v.projectTasks");
		var selectedProjectTasks = component.get("v.selectedProjectTasks");
		var warningMessageOpProject = component.find("warningMessageOpProject");
		var hideMessaage = true;

		for (var i = 0; i < selectedProjectTasks.length; i++) {
			for (var j = 0; j < projectTasks.length; j++) {
				if (selectedProjectTasks[i].Id == projectTasks[j].Id) {
					if (projectTasks[j].Project__r.RecordType.DeveloperName == "Operational") {
						$A.util.removeClass(warningMessageOpProject, 'slds-hide');
						$A.util.addClass(warningMessageOpProject, 'slds-show');
						component.find("saveButton").set("v.disabled", true);
						hideMessaage = false;
						break;
					}
				}
			}
		}

		if (hideMessaage) {
			this.hideWarningMessage(component);
		}
	},
	hideWarningMessage : function(component) {
		var warningMessageOpProject = component.find("warningMessageOpProject");

		$A.util.removeClass(warningMessageOpProject, 'slds-show');
		$A.util.addClass(warningMessageOpProject, 'slds-hide');
		component.find("saveButton").set("v.disabled", false);
	},

	saveOneDay: function(component) {
        var newTimes = [];
        // List of projectTasks
        var projectTasks = component.get("v.selectedProjectTasks");
        var newRecord    = component.get("v.newRecord");
        var currentUser  = component.get("v.CurrentUser");
        var regDate      = component.get("v.regDate");

        console.dir(projectTasks);

        console.log("## regDate: " + regDate);
        console.log("## currentUser: " + currentUser);
        console.log("## NewRecord:");
        console.dir(newRecord);
        console.dir(projectTasks);
        console.log("## reg hours: " + newRecord.Registered_Hours__c );
        console.log("## reg mins: " + newRecord.Registered_Minutes__c );
        console.log("## project tasks length : " + projectTasks.length);

        // Calculate the time and billable time for each task...
        var newRegMinutes = Math.ceil((+newRecord.Registered_Hours__c * 60 + +newRecord.Registered_Minutes__c)/projectTasks.length);
        //console.log("## 1: " + newRegMinutes);
        var newRegIsNegative = (newRegMinutes < 0 ? true : false);
        if (newRegIsNegative) {
            newRegMinutes = -1 * newRegMinutes;
        }

        var newRegHours = 0;
        if (newRegMinutes >= 60) {
            newRegHours = Math.floor(+newRegMinutes / 60);
            newRegMinutes = Math.floor(+newRegMinutes - (60 * newRegHours));
        }

        if (newRegIsNegative) {
            newRegHours = -1 * newRegHours;
            newRegMinutes = -1 * newRegMinutes;
        }

        var newBillMinutes = Math.ceil((+newRecord.Billable_Hours__c * 60 + +newRecord.Billable_Minutes__c)/projectTasks.length);
        var newBillIsNegative = (newBillMinutes < 0 ? true : false);
        if (newBillIsNegative) {
            newBillMinutes = -1 * newBillMinutes;
        }
        var newBillHours = 0;

        if (newBillMinutes >= 60) {
            newBillHours = Math.floor(+newBillMinutes / 60);
            newBillMinutes = Math.floor(+newBillMinutes - (60 * +newBillHours));
        }

        if (newBillIsNegative) {
            newBillHours = -1 * newBillHours;
            newBillMinutes = -1 * newBillMinutes;
        }

        if (this.isInputFormValid(component)) {
            projectTasks.forEach(function a (item, index) {
                console.log("## Processing Process Task: " + item.Name);
                console.log("## id: "+ item.Id);
                var time = { 'sobjectType': 'Time__c',
                                'Date__c': regDate,
                                'Project_Task__c': item.Id,
                                'Incurred_By__c': currentUser,
                                'Registered_Hours__c': newRegHours,
                                'Registered_Minutes__c': newRegMinutes,
                                'Billable_Hours__c': newBillHours,
                                'Billable_Minutes__c': newBillMinutes,
                                'Description__c': newRecord.Description__c,
                                'Main_Activity__c': newRecord.Main_Activity__c,
                                "Activity__c": newRecord.Activity__c,
                                'Time_Type__c': newRecord.Time_Type__c,
                                'Comment__c': newRecord.Comment__c,
                                'Activity_Price_Agreement__c' : newRecord.Activity_Price_Agreement__c,
                                'Project_Country__c' : newRecord.Project_Country__c,
                                'Units__c' : newRecord.Units__c
                            };
                console.log("## Record to insert: ");
                console.dir(time);
                newTimes.push(time);
            });

            this.saveNewTimeRecords(component, newTimes);
        }
	},

    isInputFormValid: function(component){
        // Validate the data
        var validTime = component.find('inputForm').reduce(function (validSoFar, inputCmp) {
            // Displays error messages for invalid fields
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);
        return validTime;
    },

	saveNewTimeRecords : function(component, newTimes){
	    var action = component.get("c.saveTime");
        action.setParams({
            "newTimes": newTimes
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                this.resetNewRecord(component);
                component.set("v.selectedProjectTasks", []);
                console.log("## Form reset.");
            } else if (state === "ERROR") {
                 var errors = response.getError();
                 if (errors) {
                    if (errors[0] && errors[0].message) {
                        var em = errors[0].message;
                        this.displayError(component, em);
                    }
                 } else {
                    console.log("Unknown error");
                 }
            }
        });
        $A.enqueueAction(action);
        console.log("## Action queued");
    },

	saveOverDays: function(component) {
	    console.log('saveOverDays');
        var newTimes = [];
        // List of projectTasks
        component.set("v.paWarning", "");
        var projectTasks = component.get("v.selectedProjectTasks");
        console.log(JSON.stringify(projectTasks));
        if($A.util.isEmpty(projectTasks)){
            component.set("v.paWarning", $A.get("$Label.c.MissingProjectTask"));
            return;
        }else if (projectTasks.length > 1){
            component.set("v.paWarning",$A.get("$Label.c.JustOneProjectTask"));
            return;
        }

        var newRecord    = component.get("v.newRecord");
        var currentUser  = component.get("v.CurrentUser");
        var startDate  = component.get("v.startDate");
        var endDate  = component.get("v.endDate");
        var hoursPerDay = component.get("v.hoursPerDay");
        var billable = component.get("v.billable");
        var skipWeekend = component.get("v.skipWeekend");
        var minutesPerDay = component.get("v.minutesPerDay");
        var billableHoursPerDay = 0;
        var billableMinutesPerDay = 0;
        if (billable == true){
            billableHoursPerDay = hoursPerDay;
            billableMinutesPerDay = minutesPerDay;
        }

        var item = projectTasks[0];
        console.log('skipWeekend -->');
        console.log(skipWeekend);

        if (this.isInputFormValid(component)){
            var daysDiff = this.getDateDiffInDays(startDate, endDate);
            if (daysDiff < 0) {
                component.set("v.paWarning","End Date has to be greater then Start Date!");
                return;
            }
            var regDate = new Date(startDate);
            var i;
            var dayOfWeek;
            for (i = 0; i <= daysDiff; i++) {
                dayOfWeek = regDate.getDay();
                if (skipWeekend == false || (skipWeekend == true && dayOfWeek !== 6 && dayOfWeek  !== 0)){
                    var time = { 'sobjectType': 'Time__c',
                                 'Date__c':regDate.toISOString(),
                                 'Project_Task__c': item.Id,
                                 'Incurred_By__c': currentUser,
                                 'Registered_Hours__c': hoursPerDay,
                                 'Registered_Minutes__c': minutesPerDay,
                                 'Billable_Hours__c': billableHoursPerDay,
                                 'Billable_Minutes__c': billableMinutesPerDay,
                                 'Description__c': newRecord.Description__c,
                                 'Main_Activity__c': newRecord.Main_Activity__c,
                                 "Activity__c": newRecord.Activity__c,
                                 'Time_Type__c': newRecord.Time_Type__c,
                                 'Comment__c': newRecord.Comment__c,
                                 'Activity_Price_Agreement__c' : newRecord.Activity_Price_Agreement__c,
                                 'Project_Country__c' : newRecord.Project_Country__c,
                                 'Units__c' : newRecord.Units__c
                             };
                     console.log("## Record to insert: ");
                     console.log(JSON.stringify(time));
                     newTimes.push(time);
                }
                regDate = this.addDays(regDate, 1);
            }
            if (!$A.util.isEmpty(newTimes)){
                this.saveNewTimeRecords(component, newTimes);
            }
        }
	},

	addDays: function(inputDate , days){
        const resultDate = new Date(inputDate);
        resultDate.setDate(resultDate.getDate() + days);
        return resultDate;
    },

	getDateDiffInDays: function(dateAsStringFrom , dateAsStringTill){
	    let diffDays = 0;
	    if(!$A.util.isEmpty(dateAsStringFrom) && !$A.util.isEmpty(dateAsStringTill)){
            let startDate = Date.parse(dateAsStringFrom);
            let endDate = Date.parse(dateAsStringTill);
            if (endDate < startDate){
                diffDays = -1;
            }else{
                const diffTime = Math.abs(endDate - startDate);
                diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
            }
        }
        return diffDays;
    },

	performSubmit: function(component) {
		console.log("## performSubmit");
		let overDay = component.get("v.overDay");
		if (overDay == true){
            this.saveOverDays(component);
        }else{
            this.saveOneDay(component);
        }
	},


	fetchActivityPicklist: function (component) {
		console.log("## fetch Activity picklist");
		
		var action = component.get("c.getActivityValues");
		// Param
		action.setParams({"mainActivityValue" : component.get("{!v.newRecord.Main_Activity__c}")});
		action.setCallback(this, function(response) {
			var state = response.getState();
			if(state === 'SUCCESS'){
				var list = response.getReturnValue();
				component.set("v.activityOptions", list);
				console.log("## Activity picklist retreived");
			}
			else if(state === 'ERROR'){
				console.log('## Error getting picklist values for Activity.');
			}
		})
		
		$A.enqueueAction(action);		
	},
	fetchMainActivityPicklist: function (component) {
		console.log("## fetch Main Activity picklist");
		
		var action = component.get("c.getMainActivityValues");
			
		action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === 'SUCCESS') {
				var list = response.getReturnValue();
				component.set("v.activityOptions", list);
				console.log("## Main Activity picklist retreived");
            }
            else if(state === 'ERROR'){
				console.log('## Error getting picklist values for Activity.');
			}
		})
		
		$A.enqueueAction(action);		
	},
	//Time Type remove
	fetchTimeTypePicklist: function (component) {
		console.log("## fetch Time Type picklist");
		var action = component.get("c.getTimeTypeValues");
		action.setCallback(this, function(response) {
			var state = response.getState();
			if(state === 'SUCCESS'){
				var list = response.getReturnValue();
				component.set("v.publicTimeTypeOptions", list);
				console.log("## Time Type picklist retreived");
				//this.liveSearchFocus(component);
            } 
            else if(state === 'ERROR'){
				console.log('## Error getting picklist values for Time Type.');
			}
		})
		$A.enqueueAction(action);
	},

	loadDefaultTimeTypeValue : function(component) {
		var action = component.get("c.getDefaultTimeTypeValue");
		action.setCallback(this, function(response) {
			if(response.getState() === 'SUCCESS') {
				component.set("v.TimeTypeDefaultValue", response.getReturnValue());

			}
		});
		$A.enqueueAction(action);
	},
	disableTimeType : function(component, disableValue) {
		for (var i = 0; i < component.find("inputForm").length; i++) {
			if (component.find("inputForm")[i].get("v.name") == "timeTypePicklist") {
				component.find("inputForm")[i].set("v.disabled", disableValue);
				return;
			}
		}
	},

   displayError: function(cmp, message) {
      console.log(message);
      var utilCmp = cmp.find("utilId");
      utilCmp.showError(message);
    },

    handleError: function(cmp, response) {
        this.hideSpinner(cmp);
        var utilCmp = cmp.find("utilId");
        utilCmp.handleError(response);
     },

   showSpinner: function(cmp) {
        var numOfRuns = cmp.get('v.numOfRuns');
        numOfRuns = numOfRuns + 1;
        cmp.set('v.numOfRuns', numOfRuns);
     },

     hideSpinner : function(cmp){
         var numOfRuns = cmp.get('v.numOfRuns');
         if (numOfRuns > 0){
            numOfRuns = numOfRuns - 1;
            cmp.set('v.numOfRuns', numOfRuns);
         }
         window.setTimeout(
             $A.getCallback(function () {
                cmp.find("live-search").focus();
             }), 500
         );
     },

   setMainPriceAgreement: function(cmp, event){
     console.log('setMainPriceAgreement');
     this.showSpinner(cmp);
     var action = cmp.get("c.getActivityPriceAgreementConfig");
     action.setCallback(this, function(response) {
         var state = response.getState();
         if (state === "SUCCESS") {
             let apa = response.getReturnValue();
             let uiSettings = apa.uiSettings;
             let workingHours = apa.numOfWorkingHours;
             let workingMinutes = apa.numOfWorkingMinutes;
             console.log('workingMinutes '+ workingMinutes);
             cmp.set("v.hoursPerDay", workingHours);
             cmp.set("v.minutesPerDay", workingMinutes);
             if (uiSettings.Time_Internal__c == true){
                 this.setProjectTaskFilterPressed(cmp,"internal");
             }
             if(uiSettings.Time_Operational__c == true){
                 this.setProjectTaskFilterPressed(cmp,"operational");
             }
             cmp.set("v.activityPriceAgreementSettings",apa);
             //console.log(JSON.stringify(apa));
             this.hideSpinner(cmp);
         }
         else if (state === "ERROR") {
             this.handleError(cmp, response);
         }
      });
      $A.enqueueAction(action);
  },

  setSelectedProjectTaskIds: function(cmp, selectedProjectTasks){
    cmp.set("v.paWarning", "");
    let selectedProjectTaskIds = [];
    var index;
    for (index = 0; index < selectedProjectTasks.length; index++) {
        let proj = selectedProjectTasks[index];
        selectedProjectTaskIds.push(proj.Id)
    }
    if(!$A.util.isEmpty(selectedProjectTaskIds)){
        this.loadActivityPriceAgreementOptions(cmp, selectedProjectTaskIds);
    }
  },

  loadActivityPriceAgreementOptions: function(cmp, selectedProjectTaskIds){
      this.showSpinner(cmp);
      var action = cmp.get("c.getActivityPriceAgreementOptions");
      action.setParams({ projTaskIds : selectedProjectTaskIds});
      action.setCallback(this, function(response) {
           var state = response.getState();
           if (state === "SUCCESS") {
               let options = response.getReturnValue();
               console.log(JSON.stringify(options));
               this.setActivityPriceAgreementOptions(cmp, options);
               this.hideSpinner(cmp);
           }
           else if (state === "ERROR") {
               this.handleError(cmp, response);
           }
        });
      $A.enqueueAction(action);
  },

  setActivityPriceAgreementOptions: function(cmp, options){
     if (!$A.util.isEmpty(options.warning)){
         cmp.set("v.paWarning",options.warning);
     }else{
         cmp.set("v.agreement",options.agreement);
     }
  },

  removeElementFromArray: function(array, element){
        const index = array.indexOf(element);
        if (index > -1) {
          array.splice(index, 1);
        }
    },

  setProjectTaskFilterPressed: function(cmp, button){
      cmp.set("v.searchKey","");
      cmp.set("v.projectTasks",[]);
      cmp.set("v.selectedProjectTasks",[]);
      cmp.set("v.body", []);
      let operationalVariant = cmp.get("v.operationalVariant");
      let internalVariant = cmp.get("v.internalVariant");
      if (button == "operational"){
          if (operationalVariant == "neutral"){
              operationalVariant = "brand";
              cmp.set("v.operationalFilter", true);
          }else{
              operationalVariant = "neutral";
              cmp.set("v.operationalFilter", false);
          }
      }
      else if (button == "internal"){
         if (internalVariant == "neutral"){
              internalVariant = "brand";
              cmp.set("v.internalFilter", true);
          }else{
              internalVariant = "neutral";
              cmp.set("v.internalFilter", false);
          }
      }
      cmp.set("v.internalVariant", internalVariant);
      cmp.set("v.operationalVariant", operationalVariant);
      this.saveFilterSetting(cmp);
    },

    saveFilterSetting: function(cmp){
        var action = cmp.get("c.setUiConf");
        console.log('saveFilterSetting');
        var operational = cmp.get("v.operationalFilter");
        var internal = cmp.get("v.internalFilter");
        console.log(operational);
        action.setParams({operationalFilter: operational, internalFilter : internal});
        action.setCallback(this, function(response) {
           var state = response.getState();
           if (state === "ERROR") {
               this.handleError(cmp, response);
           }
        });
        $A.enqueueAction(action);
    },

    setUnitAccess: function(component){
        console.log('setUnitAccess');
        let newRecord = component.get("v.newRecord");
        if (newRecord.Activity_Price_Agreement__c != 'Unit Price' &&
            newRecord.Activity_Price_Agreement__c != 'Fixed Price') {
            component.set("v.disableUnits", true);
        } else {
            component.set("v.disableUnits", false);
        }
    },

    closeModal: function(component, event){
        console.log("## Setting up event");
        var evt = $A.get("e.c:closeTimeRegistrationModal");
        evt.setParams({"restart":   false});
        console.dir(evt.toString());
        evt.fire();
        console.log("## Event fired>>  " + evt);
		console.log("## Event fired==>  " + window.location.pathname);
        var currURL = window.location.pathname;
      
        if(!currURL.includes('Log_Time')){
            var urlEvent = $A.get("e.force:navigateToURL");
			urlEvent.setParams({ "url": "/lightning/n/Log_Time" });
			urlEvent.fire();
        }
    },

    setBillable: function(component){
        console.log('setBillable');
        let newRecord = component.get("v.newRecord");
        if (newRecord.Activity_Price_Agreement__c == 'Hourly Rate') {
            component.set("v.billable", true);
        }else{
            component.set("v.billable", false);
        }
    },

    liveSearchFocus: function(component){
        let liveSearch = component.find("live-search");
        liveSearch.focus();
    },
    
    showDateErrorToast : function(component, errMessage) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Date Error',
            message: errMessage,
            messageTemplate: 'Mode is pester ,duration is 5sec and Message is overrriden',
            duration:' 5000',
            key: 'info_alt',
            type: 'error',
            mode: 'pester'
        });
        toastEvent.fire();
    },

})