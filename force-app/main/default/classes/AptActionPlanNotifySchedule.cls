/**
 * Created by jozef on 17. 5. 2023.
 * Description: Process is scheduled for every day
 */

global class AptActionPlanNotifySchedule implements Schedulable {
    public class ConfigurationException extends Exception {}

    global void execute(SchedulableContext param1) {
        Action_Plan_Automation__mdt conf
                = Action_Plan_Automation__mdt.getInstance('Notification');
        if (isTimeToRunProcess(conf)) {
            Id scheduleBatch = Database.executeBatch(new AptActionPlanNotifyBatch(conf),150);
        }
    }

    private Boolean isTimeToRunProcess(Action_Plan_Automation__mdt conf) {
        Boolean isTime = false;
        Date sysDate = System.today();
        Integer currentYear = sysDate.year();
        Date runDate;
        Integer diffDays;
        if (conf != null && conf.Creation_Date__c != null){
            runDate = getDate(conf.Creation_Date__c, currentYear);
            diffDays = sysDate.daysBetween(runDate);
            if (diffDays == conf.Number_of_days_before_creation__c){
                isTime = true;
            }
        }
        return isTime;
    }

    private Date getDate(String creationDate, Integer currentYear){
        Date runDate;
        Integer runDay, runMonth;
        List<String> creationDateList;
        try {
            System.debug(creationDate);
            creationDateList = creationDate.split('\\.');
            runDay = Integer.valueOf(creationDateList.get(0));
            runMonth = Integer.valueOf(creationDateList.get(1));
            runDate = Date.newInstance(currentYear, runMonth, runDay);
        }catch (Exception ex){
            throw new ConfigurationException('Wrong Action Plan Automation configuration : ' + creationDate
                    + ' : ' + ex.getMessage());
        }
        return runDate;
    }
}