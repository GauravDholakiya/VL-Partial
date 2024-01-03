public class ATATMembers {
    public static List<String> GetTypes(String Types) {
        Map<String,List<String>> ATAAMemberMap = new Map<String,List<String>>();
        ATAAMemberMap.put('Accounting Responsible', new List<String>{'Accounting – Shared Channel'});
        ATAAMemberMap.put('Accounting Consultant', new List<String>{'Accounting – Shared Channel'});
        ATAAMemberMap.put('Accounting Consultant 2', new List<String>{'Accounting – Shared Channel'});
        ATAAMemberMap.put('Accounting Controller', new List<String>{'Accounting – Shared Channel'});
        ATAAMemberMap.put('Customer Success Manager', new List<String>{'Accounting – Shared Channel'});
        ATAAMemberMap.put('Executive Sponsor', new List<String>{'Accounting – Shared Channel'});
        ATAAMemberMap.put('Integration_Resource', new List<String>{'Accounting – Shared Channel'});
        ATAAMemberMap.put('Project_Manager', new List<String>{'Accounting – Shared Channel'});
        ATAAMemberMap.put('Quality Consultant', new List<String>{'Accounting – Shared Channel'});
        ATAAMemberMap.put('Sales Consultant', new List<String>{'Accounting – Shared Channel'});
        ATAAMemberMap.put('Remittance Responsible', new List<String>{'Accounting – Shared Channel'});
        ATAAMemberMap.put('Year end Responcible', new List<String>{'Accounting – Shared Channel'});
        ATAAMemberMap.put('Year end Consultant', new List<String>{'Accounting – Shared Channel'});
        ATAAMemberMap.put('Quality Consultant Payroll', new List<String>{'Accounting – Shared Channel', 'Payroll – Shared Channel'});
        ATAAMemberMap.put('Payroll_Responsible', new List<String>{'Accounting – Shared Channel', 'Payroll – Shared Channel'});
        ATAAMemberMap.put('Payroll Consultant', new List<String>{'Accounting – Shared Channel', 'Payroll – Shared Channel'});
        ATAAMemberMap.put('Payroll Consultant 2', new List<String>{'Accounting – Shared Channel', 'Payroll – Shared Channel'});
        ATAAMemberMap.put('Project Manager Payroll', new List<String>{'Accounting – Shared Channel', 'Payroll – Shared Channel'});
         
        try {
            List<String> getMapData = ATAAMemberMap.get(Types);
            return getMapData;
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
            return Null;
        }
    }
}