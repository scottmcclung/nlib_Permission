/**
 * Test if any user has been assigned a custom permission
 *
 * This is heavily inspired by the wonderful work by Andy Fawcett.
 * You should read his blog at https://andyinthecloud.com and buy his book
 * 'Force.com Enterprise Patterns'
 * 
 */
public class nlib_Permission
{
  public static Boolean userHasPermission( String userId, String permissionName )
  {
    return usersHavePermission( new Assignment[]{ new Assignment( userId, permissionName ) } )[ 0 ].isAssigned;
  }
  
  
  
  
  @InvocableMethod(label='User Has Permission?' description='Tests whether a give user has been assigned a specific custom permission.')
  public static AssignmentResponse[] usersHavePermission( Assignment[] assignments )
  {
    return new nlib_Permission( assignments ).getResponses();
  }
  
  
  
  
  public class Assignment
  {
    @InvocableVariable(label='User Id' description='The record id of the user the permission is assigned to.' required=true)
    public String userId;
    
    @InvocableVariable(label='Custom Permission Name' description='The name of the permission assigned to the user.' required=true)
    public String permissionName;
    
    public Assignment()
    {
    }
    
    public Assignment( String userId, String permissionName )
    {
      this.userId = userId;
      this.permissionName = permissionName;
    }
  }
  
  
  
  
  public class AssignmentResponse
  {
    @InvocableVariable(label='Is Permission Assigned?' description='Is the permission assigned to the given user? (True/False)')
    public Boolean isAssigned;
    public String userId;
    public String permissionName;
    
    public AssignmentResponse( String userId, String permissionName, Boolean isAssigned )
    {
      this.userId = userId;
      this.permissionName = permissionName;
      this.isAssigned = isAssigned;
    }
  }
  
  
  
  
  Assignment[] assignments;
  static Map<Id, String> mapCustomPermissionsById;
  static Map<Id, Set<String>> mapPermissionsByUserId;
  
  
  
  /**
   *
   *
   * @param assignments
   */
  public nlib_Permission( Assignment[] assignments )
  {
    this.assignments = assignments;
    mapPermissionsByUserId = new Map<Id, Set<String>>();
    for(Assignment assignment : assignments) {
      mapPermissionsByUserId.put( (Id) assignment.userId, new Set<String>() );
    }
    buildPermissionMap();
  }
  
  
  
  
  public AssignmentResponse[] getResponses()
  {
    AssignmentResponse[] lstResponses = new AssignmentResponse[]{};
    for(Assignment assignment : this.assignments) {
      lstResponses.add( new AssignmentResponse(
        assignment.userId,
        assignment.permissionName,
        mapPermissionsByUserId.get( assignment.userId ).contains( assignment.permissionName )
      ) );
    }
    return lstResponses;
  }
  
  
  
  
  void buildPermissionMap()
  {
    if(mapCustomPermissionsById == null) {
      mapCustomPermissionsById = new Map<Id, String>();
      for(CustomPermission objPermission : [
        SELECT Id, DeveloperName
        FROM CustomPermission
      ]) {
        mapCustomPermissionsById.put( objPermission.Id, objPermission.DeveloperName );
      }
    }
    
    Set<Id> setPermissionSetIds = new Set<Id>();
    Map<Id, List<PermissionSetAssignment>> mapPermissionSetAssignmentsByUserId = new Map<Id, List<PermissionSetAssignment>>();
    
    for(PermissionSetAssignment objAssignment : [
      SELECT Id, PermissionSetId, AssigneeId
      FROM PermissionSetAssignment
      WHERE AssigneeId = :mapPermissionsByUserId.keySet()
    ]) {
      if(!mapPermissionSetAssignmentsByUserId.containsKey( objAssignment.AssigneeId )) {
        mapPermissionSetAssignmentsByUserId.put( objAssignment.AssigneeId, new PermissionSetAssignment[]{} );
      }
      setPermissionSetIds.add( objAssignment.PermissionSetId );
      mapPermissionSetAssignmentsByUserId.get( objAssignment.AssigneeId ).add( objAssignment );
    }
    
    
    
    Map<Id, Set<String>> mapCustomPermissionNameByPermissionSetId = new Map<Id, Set<String>>();
    
    for(SetupEntityAccess objAccess : [
      SELECT SetupEntityId, ParentId
      FROM SetupEntityAccess
      WHERE ParentId = :setPermissionSetIds
        AND SetupEntityId = :mapCustomPermissionsById.keySet()
    ]) {
      if(!mapCustomPermissionsById.containsKey( objAccess.SetupEntityId )) continue;
      
      if(!mapCustomPermissionNameByPermissionSetId.containsKey( objAccess.ParentId )) {
        mapCustomPermissionNameByPermissionSetId.put( objAccess.ParentId, new Set<String>() );
      }
      
      mapCustomPermissionNameByPermissionSetId.get( objAccess.ParentId )
        .add( mapCustomPermissionsById.get( objAccess.SetupEntityId ) );
    }
    
    
    for(Id userId : mapPermissionSetAssignmentsByUserId.keySet()) {
      for(PermissionSetAssignment objAssignment : mapPermissionSetAssignmentsByUserId.get( userId )) {
        if(!mapCustomPermissionNameByPermissionSetId.containsKey( objAssignment.PermissionSetId )) continue;
        mapPermissionsByUserId.get( userId ).addAll(
          mapCustomPermissionNameByPermissionSetId.get( objAssignment.PermissionSetId )
        );
      }
    }
  }
}