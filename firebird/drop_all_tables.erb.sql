<%
distinct("table").each do |currentTable|
currentTableSelector = "table." + currentTable
%>DROP TABLE <%=currentTable%>;
DROP GENERATOR GEN_<%=currentTable%>_ID;
<% end
%>
