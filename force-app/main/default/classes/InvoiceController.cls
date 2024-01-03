public class InvoiceController {
	
    @AuraEnabled
	public static InvoiceWrapper createInvoiceAndInvoiceLines(String projectId){
       	/*Boolean hasError = false;
        String message = '';
        List<Project_task__c> projectTasks = [Select id, Project__r.Name, (Select id, Billable_Hours__c, Billable_Minutes__c, Date__c, Incurred_By__r.Id, Incurred_By__r.Name, Main_Activity__c, Activity__c, Comment__c From Time__r Where Status__c = 'Approved') From Project_task__c Where Project__c = :projectId];
        List<Invoice_Line__c> invoiceLines = new List<Invoice_Line__c>();
        List<Time__c> times = new List<Time__c>();
        if (projectTasks.size()>0) {
            Invoice__c invoice = new Invoice__c(Project__c = projectId,
                                               Status__c = 'Draft',
                                               Name = projectTasks[0].Project__r.Name + '');
            try {
                insert invoice;
            } catch (Exception e) {
                hasError = true;
                message = 'Invoice  cannot be created. Please contact Administrator.';
            }
            
            for (Project_task__c pt : projectTasks) {
                for (Time__c t : pt.Time__r) {
                    invoiceLines.add(new Invoice_Line__c (Invoice__c = invoice.Id,
                                        Billable_Hours__c = t.Billable_Hours__c,
                                        Billable_Minutes__c = t.Billable_Minutes__c,
                                        Incurred_By__c = t.Incurred_By__r.Id,
                                        Incurred_By_Text__c = t.Incurred_By__r.Name,
                                        Activity__c = t.Activity__c,
                                        Comment__c = t.Comment__c,
                                        Date__c = t.Date__c,
                                        Main_Activity__c = t.Main_Activity__c
                                        )
                                      );
                   t.Status__c = 'Invoiced';
                   times.add(t);
                }
            }
            try {
                insert invoiceLines;
                update times;
                invoice.Status__c = 'Approved';
                update invoice;
            } catch (Exception e) {
                hasError = true;
                message = 'Invoice Lines cannot be created. Please contact Administrator.';
            }
            return new InvoiceWrapper(invoice.Id, message, hasError);
        } else {
            hasError = true;
            message = 'There is no Project Tasks';
            return new InvoiceWrapper(null, message, hasError);
        }*/
        return new InvoiceWrapper(null, null, false);
    }
    
    @AuraEnabled
	public static InvoiceWrapper createInvoiceAndInvoiceLinesRanges(String projectId, String startDate, String endDate){
       	Boolean hasError = false;
        String message = '';
        Date sDate = Date.valueOf(startDate);
        Date eDate = Date.valueOf(endDate);
        
        List<Project_task__c> projectTasks = [Select id, Project__r.Name, (Select id, Billable_Hours__c, Billable_Minutes__c, Date__c, Incurred_By__r.Id, Incurred_By__r.Name, Main_Activity__c, Activity__c, Comment__c From Time__r Where Status__c = 'Approved' AND Date__c>= :sDate AND  Date__c<=: eDate) From Project_task__c Where Project__c = :projectId];
        List<Invoice_Line__c> invoiceLines = new List<Invoice_Line__c>();
        List<Time__c> times = new List<Time__c>();
        if (projectTasks.size()>0) {
            Invoice__c invoice = new Invoice__c(Project__c = projectId,
                                               Status__c = 'Draft',
                                               Name = projectTasks[0].Project__r.Name + ' / ' + startDate + ' - '+ endDate);
            try {
                insert invoice;
            } catch (Exception e) {
                system.debug('ERROR: ' + e);
                hasError = true;
                message = 'Invoice cannot be created. Please contact Administrator. ' + e.getMessage();
            }
            
            for (Project_task__c pt : projectTasks) {
                for (Time__c t : pt.Time__r) {
                    invoiceLines.add(new Invoice_Line__c (Invoice__c = invoice.Id,
                                        Billable_Hours__c = t.Billable_Hours__c,
                                        Billable_Minutes__c = t.Billable_Minutes__c,
                                        Incurred_By__c = t.Incurred_By__r.Id,
                                        Incurred_By_Text__c = t.Incurred_By__r.Name,
                                        Activity__c = t.Activity__c,
                                        Comment__c = t.Comment__c,
                                        Date__c = t.Date__c,
                                        Main_Activity__c = t.Main_Activity__c
                                        )
                                      );
                   t.Status__c = 'Invoiced';
                   times.add(t);
                }
            }
            try {
                insert invoiceLines;
                update times;
                invoice.Status__c = 'Approved';
                update invoice;
            } catch (Exception e) {
                hasError = true;
                message = 'Invoice Lines cannot be created. Please contact Administrator. ' + e.getMessage();
            }
           
            return new InvoiceWrapper(invoice.Id, message, hasError);
        } else {
            hasError = true;
            message = 'There is no Project Tasks';
            return new InvoiceWrapper(null, message, hasError);
        }
    }
    
    @AuraEnabled
	public static TimeWrapper getInvoiceLines(String projectId, String startDate, String endDate){
        Date sDate = Date.valueOf(startDate);
        Date eDate = Date.valueOf(endDate);
       
        system.debug('StartDate 123: ' + sDate);
        List<Project_task__c> projectTasks = [Select id, (Select id, Billable_Hours__c, Billable_Minutes__c, Date__c, Incurred_By__r.Id, Incurred_By__r.Name, Main_Activity__c, Activity__c, Comment__c, Status__c From Time__r Where Date__c>= :sDate AND  Date__c<=: eDate) From Project_task__c Where Project__c = :projectId];
        List<Time__c> times = new List<Time__c>();
        List<Time__c> notApproved = new List<Time__c>();
        
        for (Project_task__c pt : projectTasks) {
            for (Time__c t : pt.Time__r) {
                if (t.Status__c == 'Approved') {
                   system.debug('Approved');
                   times.add(t); 
                } else if (t.Status__c != 'Invoiced')  {
                   notApproved.add(t);
                }
                
            }
        }
        return new TimeWrapper(times, notApproved.size());
    }
    @AuraEnabled
	public static String closeModal(){
        system.debug('CLOSE!');
        return null;
    }
    
    public class TimeWrapper {
    	@AuraEnabled
        public List<Time__c> times;
        
        @AuraEnabled
        public Integer notApproved;
        
        public TimeWrapper(List<Time__c> t, Integer nA) {
            times = t;
            notApproved = nA;
        }
    }
    public class InvoiceWrapper {
    	@AuraEnabled
        public String invoiceId;
        
        @AuraEnabled
        public String message;
        
        @AuraEnabled
        public Boolean hasError;
        
        public invoiceWrapper(String iId, String msg, Boolean hasErr) {
            invoiceId = iId;
            message = msg;
            hasError = hasErr;
        }
    }
}