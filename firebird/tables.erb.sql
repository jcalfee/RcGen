<% 
distinct("table").each do |currentTable|
currentTableSelector = "table." + currentTable
%>
CREATE TABLE <%=currentTable%> (
ID BIGINT NOT NULL,
<%= colDef currentTableSelector %>,
CONSTRAINT PK_<%=currentTable%> PRIMARY KEY (ID)
<% 
  unless rows(currentTableSelector + ",unique != ''").empty? 
  %>, CONSTRAINT U_<%=currentTable%> UNIQUE (<%= col currentTableSelector + ",unique != ''" %>)<%
  end
%>
);

CREATE GENERATOR GEN_<%=currentTable%>_ID;

SET TERM !! ;
CREATE TRIGGER <%=currentTable%>_BI FOR <%=currentTable%>
ACTIVE BEFORE INSERT POSITION 0
AS
DECLARE VARIABLE tmp DECIMAL(18,0);
BEGIN
  IF (NEW.ID IS NULL) THEN
    NEW.ID = GEN_ID(GEN_<%=currentTable%>_ID, 1);
  ELSE
  BEGIN
    tmp = GEN_ID(GEN_<%=currentTable%>_ID, 0);
    if (tmp < new.ID) then
      tmp = GEN_ID(GEN_<%=currentTable%>_ID, new.ID-tmp);
  END
END!!
SET TERM ; !!

COMMIT;

<% rows(currentTableSelector).each do |row| 
%>UPDATE RDB$RELATION_FIELDS set RDB$DESCRIPTION = '<%=row["column name"]%>'  where RDB$FIELD_NAME = '<%=row["column"].upcase%>' and RDB$RELATION_NAME = '<%=currentTable%>';
<%end #rows
%>

<%end #tables
%>

<% rows("fk != ''").each do |row|
%>ALTER TABLE <%=row['table']%> ADD CONSTRAINT FK_<%=row['table']%>_<%=row['fk']%> FOREIGN KEY(<%=row['fk']%>) REFERENCES <%=row['fk']%> (ID);
<%end #rows
%>


