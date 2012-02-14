def procedure_i currentTable, colTypeParams, whereClauseArray, insertArray
%{
SET TERM ^;

CREATE PROCEDURE P_#{currentTable}_I
 ( #{colTypeParams} ) 
RETURNS
 (ID BIGINT)
AS 
BEGIN 
 
  SELECT ID
  FROM #{currentTable}
  WHERE #{whereClauseArray.collect do|a|":#{a} = #{a}" end.join " AND "}
  INTO :ID;
  
  IF(:ID IS NULL) THEN
  BEGIN
    ID = GEN_ID(GEN_#{currentTable}_ID, 1);
    INSERT INTO #{currentTable} (ID, #{insertArray.join ","})
    VALUES (:ID, :#{insertArray.join ", :" });
  END

  SUSPEND;

END^

SET TERM ;^
}
end
