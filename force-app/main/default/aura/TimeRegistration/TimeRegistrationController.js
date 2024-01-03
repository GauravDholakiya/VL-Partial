({
	doInit : function(component, event, helper) {  
		var action = component.get("c.getCurrentUser");
		 
		action.setCallback(this, function (response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				component.set("v.CurrentUser", response.getReturnValue());
			} else if (state === "ERROR") {
				console.log("Error: " + errorMessage);
			}
		});

        $A.enqueueAction(action);
        component.set("v.activityPriceAgreementOptions", ["Unit Price", "Fixed Price", "Hourly Rate"]);
        helper.setMainPriceAgreement(component, event);
        //Time Type remove
		helper.fetchTimeTypePicklist(component);
		helper.resetNewRecord(component);
		helper.loadDefaultTimeTypeValue(component);
	},
	changedNewRecord : function(component, event, helper) {
		var newRecord = component.get("v.newRecord");
		if (newRecord.Main_Activity__c == "Internal" || newRecord.Main_Activity__c == "Interntid") {
			helper.showWarningMessage(component);
		} else {
			helper.hideWarningMessage(component);
		}
	},
	handleKeyChange: function (component, event, helper) {
		// Debouncing this method: Do not update the reactive property as long as this function is
		// being called within a delay of DELAY. This is to avoid a very large number of Apex method calls.
		window.clearTimeout(component.get("v.delayTimeout"));
		var searchKey = event.getParam("value");
        console.log("Timeout cleared.");

		component.set("v.delayTimeout", setTimeout(() => {
			component.set("v.searchKey", searchKey);
			component.set("v.isSearching", true);
            console.log("searchKey set.");
			helper.loadProjectTasks(component);
		}, 800));
	},

	handleSearchKeyChange: function (component, event, helper) {
		// This function populates the list of ProjectTasks - It is called when the searchKey attribute changes
		// which is tied into the live-search functionality.
		//helper.loadProjectTasks(component);
	},

	handleSubmit: function (component, event, helper) {
        var newRecord    = component.get("v.newRecord");
        if((newRecord.Main_Activity__c == 'Services' || newRecord.Main_Activity__c == 'Quality control') && newRecord.Description__c == null){
        	helper.showDateErrorToast(component, 'Please fill the description field');
        }
        else if(Number(newRecord.Registered_Minutes__c) > 59){
            helper.showDateErrorToast(component, 'Please enter a value less than 60');
        }
        else{
            helper.performSubmit(component);
        }
	},
	handleCancel : function(component, event, helper) {
	    helper.closeModal(component, event);
        /*
        console.log("## Setting up event");
		var evt = $A.get("e.c:closeTimeRegistrationModal");
		evt.setParams({"restart":   false});
		console.dir(evt.toString());
		evt.fire();

		console.log("## Event fired");
		*/
	},

	handleSaveAndClose: function(component, event, helper) {
        var newRecord    = component.get("v.newRecord");
        console.log('@@@ NEW REC @@@' + newRecord.Main_Activity__c);
        if(component.get("v.regDate") == null){
            helper.showDateErrorToast(component, 'Please select a Date');
        }
        else if((newRecord.Main_Activity__c == 'Services' || newRecord.Main_Activity__c == 'Quality control') && newRecord.Description__c == null){
            helper.showDateErrorToast(component, 'Please fill the description field');
        }
        else if(Number(newRecord.Registered_Minutes__c) > 59){
            helper.showDateErrorToast(component, 'Please enter a value less than 60');
        }
        else{
            helper.performSubmit(component);
            helper.closeModal(component, event);
        }
	},

	handleRegHoursChange: function (component, event, helper) {
        console.log("## handleRegHoursChange");
		var newRecord = component.get("v.newRecord");
		newRecord.Registered_Hours__c = event.getSource().get("v.value");
		if( newRecord.Activity_Price_Agreement__c != 'Unit Price' &&
			newRecord.Activity_Price_Agreement__c != 'Fixed Price') {
			newRecord.Billable_Hours__c = newRecord.Registered_Hours__c;
			component.set("v.newRecordBillableHours", newRecord.Billable_Hours__c);
		}
		component.set("v.newRecord", newRecord);
		
	},
	handleRegMinutesChange: function (component, event, helper) {
        console.log("## handleRegMinutesChange");
		var newRecord = component.get("v.newRecord");
		newRecord.Registered_Minutes__c = event.getSource().get("v.value");
		if( newRecord.Activity_Price_Agreement__c != 'Unit Price' &&
			newRecord.Activity_Price_Agreement__c != 'Fixed Price') {
            var regMinutes = Number(newRecord.Registered_Minutes__c);
            console.log("## regMinutes" + regMinutes);
            if (regMinutes > 59){
                console.log("## regMinutes 2" + regMinutes);
                helper.showDateErrorToast(component, 'Please enter a value less than 60');
                newRecord.Billable_Minutes__c = 0;
                newRecord.Billable_Hours__c = newRecord.Registered_Hours__c;
				component.set("v.newRecordBillableHours", newRecord.Billable_Hours__c);
                return;
            } else if (newRecord.Registered_Minutes__c > 0 && newRecord.Registered_Minutes__c <= 15) {
				newRecord.Billable_Minutes__c = 15;
                newRecord.Billable_Hours__c = newRecord.Registered_Hours__c;
				component.set("v.newRecordBillableHours", newRecord.Billable_Hours__c);
			} else if (newRecord.Registered_Minutes__c > 15 && newRecord.Registered_Minutes__c <= 30) {
				newRecord.Billable_Minutes__c = 30;
                newRecord.Billable_Hours__c = newRecord.Registered_Hours__c;
				component.set("v.newRecordBillableHours", newRecord.Billable_Hours__c);
            } else if (newRecord.Registered_Minutes__c > 30 && newRecord.Registered_Minutes__c <= 45) {
				newRecord.Billable_Minutes__c = 45;
                newRecord.Billable_Hours__c = newRecord.Registered_Hours__c;
				component.set("v.newRecordBillableHours", newRecord.Billable_Hours__c);
            } else if (newRecord.Registered_Minutes__c > 45 && newRecord.Registered_Minutes__c < 60) {
				newRecord.Billable_Minutes__c = 0;
                var billHours = Number(newRecord.Billable_Hours__c);
                billHours = billHours + 1
                newRecord.Billable_Hours__c = billHours;
                component.set("v.newRecordBillableHours", newRecord.Billable_Hours__c);
			} 
			component.set("v.newRecordBillableMinutes", newRecord.Billable_Minutes__c);
		}
		component.set("v.newRecord", newRecord);
	},
	handleBillHoursChange: function (component, event, helper) {
        console.log("## handleBillHoursChange");
		var newRecord = component.get("v.newRecord");
		newRecord.Billable_Hours__c = event.getSource().get("v.value");
        var sumRegisteredTime = (newRecord.Registered_Hours__c != undefined && newRecord.Registered_Hours__c != null && newRecord.Registered_Hours__c != ""?parseFloat(newRecord.Registered_Hours__c)*60:0);
        sumRegisteredTime += (newRecord.Registered_Minutes__c != undefined && newRecord.Registered_Minutes__c != null && newRecord.Registered_Minutes__c != ""?parseFloat(newRecord.Registered_Minutes__c):0);
        var sumBillTime = (newRecord.Billable_Hours__c != undefined && newRecord.Billable_Hours__c != null && newRecord.Billable_Hours__c != ""?parseFloat(newRecord.Billable_Hours__c)*60:0);
        sumBillTime += (newRecord.Billable_Minutes__c != undefined && newRecord.Billable_Minutes__c != null && newRecord.Billable_Minutes__c != ""?parseFloat(newRecord.Billable_Minutes__c):0);
        if (newRecord.Activity_Price_Agreement__c != 'Unit Price' &&
			newRecord.Activity_Price_Agreement__c != 'Fixed Price' &&
           sumBillTime < sumRegisteredTime) {
            component.set("v.commentRequired", true);
	    } else {
            component.set("v.commentRequired", false);            
        }
		console.log("## v.commentRequired", component.get("v.commentRequired"));
		component.set("v.newRecord", newRecord);
	},
	handleBillMinutesChange: function (component, event, helper) {
        console.log("## handleBillMinutesChange");
		var newRecord = component.get("v.newRecord");   
		newRecord.Billable_Minutes__c = event.getSource().get("v.value");
        var sumRegisteredTime = (newRecord.Registered_Hours__c != undefined && newRecord.Registered_Hours__c != null && newRecord.Registered_Hours__c != ""?parseFloat(newRecord.Registered_Hours__c)*60:0);
        sumRegisteredTime += (newRecord.Registered_Minutes__c != undefined && newRecord.Registered_Minutes__c != null && newRecord.Registered_Minutes__c != ""?parseFloat(newRecord.Registered_Minutes__c):0);
        var sumBillTime = (newRecord.Billable_Hours__c != undefined && newRecord.Billable_Hours__c != null && newRecord.Billable_Hours__c != ""?parseFloat(newRecord.Billable_Hours__c)*60:0);
        sumBillTime += (newRecord.Billable_Minutes__c != undefined && newRecord.Billable_Minutes__c != null && newRecord.Billable_Minutes__c != ""?parseFloat(newRecord.Billable_Minutes__c):0);
        if (newRecord.Activity_Price_Agreement__c != 'Unit Price' &&
			newRecord.Activity_Price_Agreement__c != 'Fixed Price' &&
           sumBillTime < sumRegisteredTime) {
            component.set("v.commentRequired", true);
	    } else {
            component.set("v.commentRequired", false);            
        }
        console.log("## v.commentRequired", component.get("v.commentRequired"));
		component.set("v.newRecord", newRecord);
	},
	handlePriceAgreementChange: function(component, event, helper) {
        console.log("## handlePriceAgreementChange");
        helper.setUnitAccess(component);
        helper.setBillable(component);
	},
	handleProjectTaskSelected : function(component, event, helper) {
		var selectedList = component.get("v.selectedProjectTaskList");
        console.log("## Setting Project Task Country...");
        console.log("## project tasks: ");
        console.dir(selectedList);
        console.log("## Remove: " + event.getParam("Id"));

        var projectTasks = component.get("v.projectTasks");
		var selectedProjectTasks = component.get("v.selectedProjectTasks");

        helper.setSelectedProjectTaskIds(component,selectedProjectTasks);
		var newRecord = component.get("v.newRecord");
		newRecord.Activity_Price_Agreement__c = "Hourly Rate";
        if (selectedProjectTasks.length != 0) {
            //Time Type remove
			var timeTypeOptions = [];
			for (var i = 0; i < selectedProjectTasks.length; i++) {
				if (selectedProjectTasks.length == 1) {
					newRecord.Time_Type__c = selectedProjectTasks[i].DefaultTimeType;
				}
				if (selectedProjectTasks[i].LockTimeType) {
					if (selectedProjectTasks.length > 1) {
						selectedProjectTasks.pop();
						component.set("v.selectedProjectTasks", selectedProjectTasks);
						var warningMessagePrivateProject = component.find("warningMessagePrivateProject");
						$A.util.removeClass(warningMessagePrivateProject, 'slds-hide');
						$A.util.addClass(warningMessagePrivateProject, 'slds-show');
						setTimeout(function(){ 
							var warningMessagePrivateProject = component.find("warningMessagePrivateProject");
							$A.util.removeClass(warningMessagePrivateProject, 'slds-show');
							$A.util.addClass(warningMessagePrivateProject, 'slds-hide');
						}, 2000);
						return;
					}
					//Time Type remove
					timeTypeOptions.push(newRecord.Time_Type__c);
					component.set("v.timeTypeOptions", timeTypeOptions);
					helper.disableTimeType(component, true);
				}
				//Time Type remove
				else {
					component.set("v.timeTypeOptions", component.get("v.publicTimeTypeOptions"));
					helper.disableTimeType(component, false);
				}

			}


            for (var j = 0; j < projectTasks.length; j++) {
                if (selectedProjectTasks[selectedProjectTasks.length - 1].Id == projectTasks[j].Id) {
                    if (projectTasks[j].Project__r.RecordType.DeveloperName == "Internal_Project") {
						newRecord.Activity_Price_Agreement__c = "Fixed Price";
                    }
                }
			}
		}

		component.set("v.newRecord", newRecord);

		if (selectedList == undefined || selectedList.length == 0) {
			var action = component.get("c.getProjectTaskCountry");
			action.setParams({
				"projectTaskId": event.getParam("Id")			
			}); 
				action.setCallback(this, function (response) {
					var state = response.getState();
					if (state === "SUCCESS") {
                        console.log("## New Project Country is: " + response.getReturnValue());
                        //component.set("v.newRecord.Project_Country__c", response.getReturnValue());
						component.set("v.noCountrySet", false);

						var evt = $A.get("e.c:projectCountrySet");
						evt.setParams({"Value" : response.getReturnValue()});
						evt.fire();
                        console.log("## Fired projectCountrySet event");

					} else if (state === "ERROR") {
					console.log("Error: " + errorMessage);
				}        
			});        
			$A.enqueueAction(action);      
			
			var action2 = component.get("c.getMainPriceAgreement");
			action2.setParams({
				"projectTaskId": event.getParam("Id")
			}); 
			action2.setCallback(this, function (response) {
				var state = response.getState();
				if (state === "SUCCESS") {
                        console.log("## New Main Price Agreement is: " + response.getReturnValue());
					component.set("v.newRecord.Main_Price_Agreement__c", response.getReturnValue());
				} else if (state === "ERROR") {
					console.log("Error: " + errorMessage);
				}
			});
			$A.enqueueAction(action2);
                   
		} else {
			console.log("## Project task added but not changing country");
		}
		
		newRecord = component.get("v.newRecord");
		if (newRecord.Main_Activity__c == "Internal" || newRecord.Main_Activity__c == "Interntid") {
			helper.showWarningMessage(component);
		} else {
			helper.hideWarningMessage(component);
		}
	},
	handleProjectTaskDeselected : function(component, event, helper) {
	    console.log('handleProjectTaskDeselected');
		var selectedList = component.get("v.selectedProjectTasks");
        helper.setSelectedProjectTaskIds(component,selectedList);

		console.log("## Removing Project Task Country...");

		var newRecord = component.get("v.newRecord");
		if (selectedList.length == 0) {
			helper.resetNewRecord(component);
			var evt = $A.get("e.c:projectCountrySet");
			evt.setParams({"Value" : "--- None ---"});
			evt.fire();
		}
		
		if (newRecord.Main_Activity__c == "Internal" || newRecord.Main_Activity__c == "Interntid") {
			helper.showWarningMessage(component);
		} else {
			helper.hideWarningMessage(component);
		}

        //if (selectedList.length == 1) {
            //component.set("v.newRecord.Project_Country__c", '--- None ---');
            //component.set("v.noCountrySet", true);
        //}        
	},

	handleActivitySelected : function(component, event, helper) {
	    var activity = event.getParam("activity");
	    console.log('handleActivitySelected = ' + activity);
        let config = component.get("v.activityPriceAgreementSettings");
        let paWarning = component.get("v.paWarning");
        let agreement = component.get("v.agreement");
        let newRecord = component.get("v.newRecord");
        let activityPriceAgreementOptions = ["Unit Price", "Fixed Price", "Hourly Rate"];
        component.set("v.activityPriceAgreementOptions", activityPriceAgreementOptions );
        let valueNotAllowed = [];
        let defaultValue = 'Hourly Rate';
        if (!$A.util.isEmpty(config.settings) && $A.util.isEmpty(paWarning)){
            const setting = config.settings.find(el => el.Activity__c == activity);
            console.log(setting);
            if (!$A.util.isEmpty(setting)){
                if(!$A.util.isEmpty(setting.Value_not_allowed__c)){
                    valueNotAllowed = setting.Value_not_allowed__c.split(";");
                    activityPriceAgreementOptions = activityPriceAgreementOptions.filter( function( el ) {
                        return valueNotAllowed.indexOf( el ) < 0;
                    });
                }
                if(!$A.util.isEmpty(setting.Exception__c)){
                    const ex = activityPriceAgreementOptions.find(el => el == setting.Exception__c);
                    if ($A.util.isEmpty(ex)){
                        activityPriceAgreementOptions.push(setting.Exception__c);
                    }
                }
                if (!$A.util.isEmpty(agreement) && !$A.util.isEmpty(setting.Price_Agreement_Field__c)){
                    console.log(JSON.stringify(agreement));
                    defaultValue = agreement[setting.Price_Agreement_Field__c];
                    if (!$A.util.isEmpty(defaultValue)) {
                        const val = valueNotAllowed.find(el => el == defaultValue);
                        if (!$A.util.isEmpty(val)){
                            defaultValue = setting.Exception__c;
                        }
                    }
                }
                if ("undefined" == typeof(defaultValue)){
                    defaultValue = "Hourly Rate";
                }
                newRecord.Activity_Price_Agreement__c = defaultValue;
                console.log('newRecord.Activity_Price_Agreement__c = ' + newRecord.Activity_Price_Agreement__c);
                component.set("v.activityPriceAgreementOptions", activityPriceAgreementOptions );
                window.setTimeout(
                     $A.getCallback(function() {
                         //This needs to be implemented better by <option text="{!option.label}"
                         //value="{!option.id}" selected="{!option.selected}"/>
                         component.set("v.newRecord", newRecord );
                         helper.setUnitAccess(component);
                         helper.setBillable(component);
                     }), 500
                );
            }
        }
	},

	handleOperationalPressed: function(component, event, helper) {
        helper.setProjectTaskFilterPressed(component,"operational");
        helper.liveSearchFocus(component);
	},

    handleInternalPressed: function(component, event, helper) {
        helper.setProjectTaskFilterPressed(component,"internal");
        helper.liveSearchFocus(component);
    },


})