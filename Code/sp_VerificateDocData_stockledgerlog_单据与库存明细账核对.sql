/*
单据与库存明细账的核对
*/
create proc sp_VerificateDocData_stockledgerlog
	@TaskID varchar(50),
	@BeginDate DATETIME,
	@EndDate datetime,
	@FormIDList varchar(200)='',
	@CompanyIDList varchar(200)='',
	@SDOrgList varchar(500)='',
	@StcodeList varchar(500)='',
	@DoccodeList varchar(500)='',
	@Remark varchar(500)='',
	@Usercode varchar(30)='',
	@TerminalID varchar(50)=''
as
	BEGIN
		set NOCOUNT ON
		/*
			1.校验组织结构数据是否正确,以仓库为准
			
		*/
		/*
		1.有单据没明细账
		2.有明细账没单据
		
		*/
		declare @TaskInstanceID varchar(50)
		select @TaskInstanceID=newid()
		--@TaskID=1	　检查单据与业务表是否一致,检查指定功能号的数据行数是否一致
		--校验Commsales_h与Commsales_d表
		if @FormIDList='' or exists(select 1 from commondb.dbo.split(@FormIDList,',') s where s.List in(4630,4631))
			BEGIN
				with cte as(
					select a.FormID,a.companyid,a.DocDate,count(*) as cnt 
					  from Commsales_h  a with(nolock) inner join Commsales_d b with(nolock) on a.DocCode=b.DocCode
					where (@CompanyIDList='' or exists(select 1 from commondb.dbo.SPLIT(@CompanyIDList,',') s where s.List=a.CompanyID))
					and (@FormIDList='' or exists(select 1 from commondb.dbo.SPLIT(@FormIDList,',') s where s.List=a.FormID))
					and (@DoccodeList='' or exists(select 1 from commondb.dbo.SPLIT(@DoccodeList,',') s where s.List=a.DocCode))
					and (@StcodeList='' or exists(select 1 from commondb.dbo.SPLIT(@StcodeList,',') s where s.List=a.stcode))
					and (@SDOrgList='' or exists(select 1 from commondb.dbo.SPLIT(@SDOrgList,',') s where s.List=a.sdorgid))
					and a.DocDate between @BeginDate and @EndDate
					and a.formid in(4630,4631)
					group by a.FormID,a.companyid,a.DocDate
					),
				cte1 as(
					select a.FormID,a.companyid,a.DocDate,count(*) cnt
					from urp32.jturp.dbo.SOP_FACT_ALL_BUSINESS a with(nolock)
						where (@CompanyIDList='' or exists(select 1 from commondb.dbo.SPLIT(@CompanyIDList,',') s where s.List=a.CompanyID))
						and (@FormIDList='' or exists(select 1 from commondb.dbo.SPLIT(@FormIDList,',') s where s.List=a.FormID))
						and (@DoccodeList='' or exists(select 1 from commondb.dbo.SPLIT(@DoccodeList,',') s where s.List=a.DocCode))
						and (@StcodeList='' or exists(select 1 from commondb.dbo.SPLIT(@StcodeList,',') s where s.List=a.stcode))
						and (@SDOrgList='' or exists(select 1 from commondb.dbo.SPLIT(@SDOrgList,',') s where s.List=a.sdorgid))
						and a.DocDate between @BeginDate and @EndDate
						and a.formid in(4630,4631)
						group by a.FormID,a.companyid,a.DocDate
					)
				insert into DataVerificationLog(TaskID,TaskInstanceID,OperDate,OperName,DocDate,FormID,FormType,companyid,Digit,Digit2, Remark)
				select @TaskID,@TaskInstanceID,getdate(),@Usercode,a.docdate,a.formid,5,a.companyid,a.cnt,b.cnt,'业务数量不一致.'
				  from cte a full join cte1 b on a.formid=b.formid and a.docdate=b.docdate and a.companyid=b.companyid
				where isnull(a.cnt,0)<>isnull(b.cnt,0)
			END
		--校验imatdoc_h与imatdoc_d表
		if @FormIDList='' or exists(select 1 from commondb.dbo.split(@FormIDList,',') s where s.List in(1501,1504,1507,1509,1512,1520,1523,1598,1599,4061,4062))
			BEGIN
				with cte as(
					select a.FormID,a.companyid,a.DocDate,count(*) as cnt 
					  from imatdoc_h  a with(nolock) inner join imatdoc_d b with(nolock) on a.DocCode=b.DocCode
					where (@CompanyIDList='' or exists(select 1 from commondb.dbo.SPLIT(@CompanyIDList,',') s where s.List=a.CompanyID))
					and (@FormIDList='' or exists(select 1 from commondb.dbo.SPLIT(@FormIDList,',') s where s.List=a.FormID))
					and (@DoccodeList='' or exists(select 1 from commondb.dbo.SPLIT(@DoccodeList,',') s where s.List=a.DocCode))
					and (@StcodeList='' or exists(select 1 from commondb.dbo.SPLIT(@StcodeList,',') s where s.List=a.stcode))
					and (@SDOrgList='' or exists(select 1 from commondb.dbo.SPLIT(@SDOrgList,',') s where s.List=a.sdorgid))
					and a.DocDate between @BeginDate and @EndDate
					and a.formid in(1501,1504,1507,1509,1512,1520,1523,1598,1599,4061,4062)
					group by a.FormID,a.companyid,a.DocDate
					),
				cte1 as(
					select a.FormID,a.companyid,a.DocDate,count(*) cnt
					from urp32.jturp.dbo.SOP_FACT_ALL_BUSINESS a with(nolock)
						where (@CompanyIDList='' or exists(select 1 from commondb.dbo.SPLIT(@CompanyIDList,',') s where s.List=a.CompanyID))
						and (@FormIDList='' or exists(select 1 from commondb.dbo.SPLIT(@FormIDList,',') s where s.List=a.FormID))
						and (@DoccodeList='' or exists(select 1 from commondb.dbo.SPLIT(@DoccodeList,',') s where s.List=a.DocCode))
						and (@StcodeList='' or exists(select 1 from commondb.dbo.SPLIT(@StcodeList,',') s where s.List=a.stcode))
						and (@SDOrgList='' or exists(select 1 from commondb.dbo.SPLIT(@SDOrgList,',') s where s.List=a.sdorgid))
						and a.DocDate between @BeginDate and @EndDate
						and a.formid in(1501,1504,1507,1509,1512,1520,1523,1598,1599,4061,4062)
						group by a.FormID,a.companyid,a.DocDate
					)
				insert into DataVerificationLog(TaskID,TaskInstanceID,OperDate,OperName,DocDate,FormID,FormType,companyid,Digit,Digit2, Remark)
				select @TaskID,@TaskInstanceID,getdate(),@Usercode,a.docdate,a.formid,5,a.companyid,a.cnt,b.cnt,'业务数量不一致.'
				  from cte a full join cte1 b on a.formid=b.formid and a.docdate=b.docdate and a.companyid=b.companyid
				where isnull(a.cnt,0)<>isnull(b.cnt,0)
			END
			--校验iseriesloghd与iserieslogitem表
			if @FormIDList='' or exists(select 1 from commondb.dbo.split(@FormIDList,',') s where s.List in(1553,1557))
			BEGIN
				with cte as(
					select a.FormID,a.companyid,a.DocDate,count(*) as cnt 
					from iseriesloghd   a with(nolock) inner join iserieslogitem  b with(nolock) on a.DocCode=b.DocCode
					where (@CompanyIDList='' or exists(select 1 from commondb.dbo.SPLIT(@CompanyIDList,',') s where s.List=a.CompanyID))
					and (@FormIDList='' or exists(select 1 from commondb.dbo.SPLIT(@FormIDList,',') s where s.List=a.FormID))
					and (@DoccodeList='' or exists(select 1 from commondb.dbo.SPLIT(@DoccodeList,',') s where s.List=a.DocCode))
					and (@StcodeList='' or exists(select 1 from commondb.dbo.SPLIT(@StcodeList,',') s where s.List=a.stcode))
					and (@SDOrgList='' or exists(select 1 from commondb.dbo.SPLIT(@SDOrgList,',') s where s.List=a.sdorgid))
					and a.DocDate between @BeginDate and @EndDate
					and a.formid in(1553,1557)
					group by a.FormID,a.companyid,a.DocDate
					),
				cte1 as(
					select a.FormID,a.companyid,a.DocDate,count(*) cnt
					from urp32.jturp.dbo.SOP_FACT_ALL_BUSINESS a with(nolock)
						where (@CompanyIDList='' or exists(select 1 from commondb.dbo.SPLIT(@CompanyIDList,',') s where s.List=a.CompanyID))
						and (@FormIDList='' or exists(select 1 from commondb.dbo.SPLIT(@FormIDList,',') s where s.List=a.FormID))
						and (@DoccodeList='' or exists(select 1 from commondb.dbo.SPLIT(@DoccodeList,',') s where s.List=a.DocCode))
						and (@StcodeList='' or exists(select 1 from commondb.dbo.SPLIT(@StcodeList,',') s where s.List=a.stcode))
						and (@SDOrgList='' or exists(select 1 from commondb.dbo.SPLIT(@SDOrgList,',') s where s.List=a.sdorgid))
						and a.DocDate between @BeginDate and @EndDate
						and a.formid in(1553,1557)
						group by a.FormID,a.companyid,a.DocDate
					)
				insert into DataVerificationLog(TaskID,TaskInstanceID,OperDate,OperName,DocDate,FormID,FormType,companyid,Digit,Digit2, Remark)
				select @TaskID,@TaskInstanceID,getdate(),@Usercode,a.docdate,a.formid,5,a.companyid,a.cnt,b.cnt,'业务数量不一致.'
				  from cte a full join cte1 b on a.formid=b.formid and a.docdate=b.docdate and a.companyid=b.companyid
				where isnull(a.cnt,0)<>isnull(b.cnt,0)
			END
			--校验sPickorderHD与sPickrderitem表
			if @FormIDList='' or exists(select 1 from commondb.dbo.split(@FormIDList,',') s where s.List in(2401,2418,2419,2420,2424,2450,4031,4032,4950,4951))
				BEGIN
					with cte as(
						select a.FormID,a.companyid,a.DocDate,count(*) as cnt 
						from iseriesloghd   a with(nolock) inner join iserieslogitem  b with(nolock) on a.DocCode=b.DocCode
						where (@CompanyIDList='' or exists(select 1 from commondb.dbo.SPLIT(@CompanyIDList,',') s where s.List=a.CompanyID))
						and (@FormIDList='' or exists(select 1 from commondb.dbo.SPLIT(@FormIDList,',') s where s.List=a.FormID))
						and (@DoccodeList='' or exists(select 1 from commondb.dbo.SPLIT(@DoccodeList,',') s where s.List=a.DocCode))
						and (@StcodeList='' or exists(select 1 from commondb.dbo.SPLIT(@StcodeList,',') s where s.List=a.stcode))
						and (@SDOrgList='' or exists(select 1 from commondb.dbo.SPLIT(@SDOrgList,',') s where s.List=a.sdorgid))
						and a.DocDate between @BeginDate and @EndDate
						and a.formid in(2401,2418,2419,2420,2424,2450,4031,4032,4950,4951)
						group by a.FormID,a.companyid,a.DocDate
						),
					cte1 as(
						select a.FormID,a.companyid,a.DocDate,count(*) cnt
						from urp32.jturp.dbo.SOP_FACT_ALL_BUSINESS a with(nolock)
							where (@CompanyIDList='' or exists(select 1 from commondb.dbo.SPLIT(@CompanyIDList,',') s where s.List=a.CompanyID))
							and (@FormIDList='' or exists(select 1 from commondb.dbo.SPLIT(@FormIDList,',') s where s.List=a.FormID))
							and (@DoccodeList='' or exists(select 1 from commondb.dbo.SPLIT(@DoccodeList,',') s where s.List=a.DocCode))
							and (@StcodeList='' or exists(select 1 from commondb.dbo.SPLIT(@StcodeList,',') s where s.List=a.stcode))
							and (@SDOrgList='' or exists(select 1 from commondb.dbo.SPLIT(@SDOrgList,',') s where s.List=a.sdorgid))
							and a.DocDate between @BeginDate and @EndDate
							and a.formid in(2401,2418,2419,2420,2424,2450,4031,4032,4950,4951)
							group by a.FormID,a.companyid,a.DocDate
						)
					insert into DataVerificationLog(TaskID,TaskInstanceID,OperDate,OperName,DocDate,FormID,FormType,companyid,Digit,Digit2, Remark)
					select @TaskID,@TaskInstanceID,getdate(),@Usercode,a.docdate,a.formid,5,a.companyid,a.cnt,b.cnt,'业务数量不一致.'
					  from cte a full join cte1 b on a.formid=b.formid and a.docdate=b.docdate and a.companyid=b.companyid
					where isnull(a.cnt,0)<>isnull(b.cnt,0)
				END

		return
	END
 