﻿<!--#include file="../../inc/AspCms_SettingClass.asp" -->
<%
CheckAdmin("AspCms_FileManger.asp")
dim action : action=getForm("action","get")

Select  case action
	case "delallfile" : delAllFile
End Select 

dim dirpath,parentPath,countnum
countnum=1

dirpath=getForm("dirpath","get")

Sub uplpadFileList
dim path,fileListArray,i,fileAttr,folderListArray,folderAttr
	path = sitePath&"/upLoad"	
	if not isExistFolder(path) then createFolder path,"folderdir"
	if not isnul(getForm("dirpath","get")) then
		path=getForm("dirpath","get")
		parentPath=Mid(getForm("dirpath","get"),1,InstrRev(getForm("dirpath","get"),"/")-1)
	end if
	
	if not instr(path,"upLoad")>0 then	
		echo "<tr bgcolor=""#FFFFFF"" align=""center""><td colspan=""7"" algin=""center"">你无限访问些目录,<a href=""javascript:history.go(-1)"" class=""txt_C1"">返回</a></td></tr>"
		response.end
	end if
	
	if not isExistFolder(path) then	
		echo "<tr bgcolor=""#FFFFFF"" align=""center""><td colspan=""7"" algin=""center"">没有这个目录,<a href=""javascript:history.go(-1)"" class=""txt_C1"">返回</a></td></tr>"
		response.end
	end if
	folderListArray=getFolderList(path)
	if instr(folderListArray(0),",")>0 then
		for i=0 to ubound(folderListArray)
			folderAttr=split(folderListArray(i),",")
			 echo "<tr bgcolor=""#ffffff"" align=""center"" onMouseOver=""this.bgColor='#CDE6FF'"" onMouseOut=""this.bgColor='#FFFFFF'"">"&vbcrlf& _
			"<td height=""28""><input type=""checkbox"" name=""path"" value="""&folderAttr(4)&""" class=""checkbox"" /></td>"&vbcrlf& _
			"<td>"&i+1&"</td>"&vbcrlf& _
			"<td><a class=""txt_C1"" href=""?dirpath="&folderAttr(4)&""">"&folderAttr(0)&"</a></td>"&vbcrlf& _
			"<td>"&folderAttr(2)&"</td>"&vbcrlf& _
			"<td>"&folderAttr(1)&"</td>"&vbcrlf& _
			"<td>"&folderAttr(3)&"</td>"&vbcrlf& _
			"<td><a href=""?action=delallfile&path="&folderAttr(4)&""" class=""txt_C1"" onClick=""return confirm('确定要删除吗')"">删除</a></td>"&vbcrlf& _
			"</tr>"&vbcrlf
		next
	end if	
	
	fileListArray= getFileList(path)
	if instr(fileListArray(0),",")>0 then	
		for  i = 0 to ubound(fileListArray)
			fileAttr=split(fileListArray(i),",")
			 echo "<tr bgcolor=""#ffffff"" align=""center"" onMouseOver=""this.bgColor='#CDE6FF'"" onMouseOut=""this.bgColor='#FFFFFF'"">"&vbcrlf& _
			"<td height=""28""><input type=""checkbox"" name=""path"" value="""&fileAttr(4)&""" class=""checkbox"" /></td>"&vbcrlf& _
			"<td>"&i+1&"</td>"&vbcrlf& _
			"<td><a target=""_blank"" href="""&fileAttr(4)&""">"&fileAttr(0)&"</a></td>"&vbcrlf& _
			"<td>"&fileAttr(2)&"</td>"&vbcrlf& _
			"<td>"&fileAttr(1)&"</td>"&vbcrlf& _
			"<td>"&fileAttr(3)&"</td>"&vbcrlf& _
			"<td><a href=""?action=delallfile&path="&fileAttr(4)&"&dirpath="&dirpath&""" class=""txt_C1"" onClick=""return confirm('确定要删除吗')"">删除</a></td>"&vbcrlf& _
			"</tr>"&vbcrlf
		next		
	end if
	
	if not instr(folderListArray(0),",")>0  and not instr(fileListArray(0),",")>0 then
		echo "<tr bgcolor=""#FFFFFF"" align=""center""><td colspan=""7"" algin=""center"">空文件夹,<a href=""javascript:history.go(-1)"" class=""txt_C1"">返回</a></td></tr>"
	end if
End Sub

Sub delAllFile
	dim ids,idsArray,arrayLen,i
	ids=replace(getForm("path","both")," ","")
	idsArray = split(ids,",") : arrayLen=ubound(idsArray)
	for i=0 to arrayLen
		if isExistFolder(idsArray(i))then delFolder idsArray(i)
		if isExistFile(idsArray(i))then delFile idsArray(i)	
	next
	dirpath =getForm("dirpath","both")
	alertMsgAndGo "删除成功",getPageName()&"?dirpath="&dirpath
End Sub


Function getAllFileList(path,countnum)
	dim fileListArray,i,fileAttr,folderListArray,folderAttr,parentPath
	if not isExistFolder(path) then createFolder path,"folderdir"	
	
	if not instr(path,"upLoad")>0 then	
		echo "<tr bgcolor=""#FFFFFF"" align=""center""><td colspan=""7"" algin=""center"">你无限访问些目录,<a href=""javascript:history.go(-1)"" class=""txt_C1"">返回</a></td></tr>"
		response.end
	end if

	if not isExistFolder(path) then	
		echo "<tr bgcolor=""#FFFFFF"" align=""center""><td colspan=""7"" algin=""center"">没有这个目录,<a href=""javascript:history.go(-1)"" class=""txt_C1"">返回</a></td></tr>"
		response.end
	end if
	folderListArray=getFolderList(path)
	if instr(folderListArray(0),",")>0 then
		for i=0 to ubound(folderListArray)
			folderAttr=split(folderListArray(i),",")	
			if isExistFolder(folderAttr(4)) then
				getAllFileList folderAttr(4),countnum
			end if
		next
	end if	
	
	dim rsObj,rsObj1 ,rsObj2,rsObj3,rsObj4
	fileListArray= getFileList(path)
	if instr(fileListArray(0),",")>0 then	
		for  i = 0 to ubound(fileListArray)
			fileAttr=split(fileListArray(i),",")
			dim finame
			finame=replace(fileAttr(4),sitePath,"")
			Set rsObj=Conn.Exec("select count(*) from {prefix}Content where IndexImage like '%"&finame&"%' or ImagePath like '%"&finame&"%' or DownURL like '%"&finame&"%' or Content like '%"&finame&"%' ","r1")
			
			Set rsObj1=Conn.Exec("select count(*) from {prefix}Links where ImageURL like '%"&finame&"%' ","r1")
			Set rsObj2=Conn.Exec("select count(*) from {prefix}Language where SiteLogoUrl like '%"&finame&"%' ","r1")
			Set rsObj3=Conn.Exec("select count(*) from {prefix}Adv where AdvImg like '%"&finame&"%' ","r1")
			Set rsObj4=Conn.Exec("select count(*) from {prefix}Sort where SortContent like '%"&finame&"%' ","r1")

			if not rsObj(0)>0 and not rsObj1(0)>0 and not rsObj2(0)>0 and not rsObj3(0)>0 and not rsObj4(0)>0 and not instr(lcase(slideImgs),lcase(finame))>0 then			
			 echo "<tr bgcolor=""#ffffff"" align=""center"" onMouseOver=""this.bgColor='#CDE6FF'"" onMouseOut=""this.bgColor='#FFFFFF'"">"&vbcrlf& _
				"<td><input type=""checkbox"" name=""path"" value="""&fileAttr(4)&""" class=""checkbox"" /></td>"&vbcrlf& _
				"<td height=""28"">"&countnum&"</td>"&vbcrlf& _
				"<td><a target=""_blank"" href="""&fileAttr(4)&""">"&fileAttr(0)&"</a></td>"&vbcrlf& _
				"<td>"&fileAttr(2)&"</td>"&vbcrlf& _
				"<td>"&fileAttr(1)&"</td>"&vbcrlf& _
				"<td>"&fileAttr(3)&"</td>"&vbcrlf& _
				"<td><a href=""?action=delallfile&path="&fileAttr(4)&""" class=""txt_C1"" onClick=""return confirm('确定要删除吗')"">删除</a></td>"&vbcrlf& _
				"</tr>"&vbcrlf
				countnum=countnum+1
				'if countnum>99 then exit Function
			end if
		next		
		rsObj.close :set rsObj=nothing
		rsObj1.close :set rsObj1=nothing
		rsObj2.close :set rsObj2=nothing
		rsObj4.close :set rsObj4=nothing
	end if
End Function
%>
