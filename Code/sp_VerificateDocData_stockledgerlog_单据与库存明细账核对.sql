/*
����������ϸ�˵ĺ˶�
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
			1.У����֯�ṹ�����Ƿ���ȷ,�Բֿ�Ϊ׼
			
		*/
		/*
		1.�е���û��ϸ��
		2.����ϸ��û����
		
		*/
		declare @TaskInstanceID varchar(50)
		select @TaskInstanceID=newid()
		--@TaskID=1	����鵥����ҵ����Ƿ�һ��,���ָ�����ܺŵ����������Ƿ�һ��
		--У��Commsales_h��Commsales_d��
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
				select @TaskID,@TaskInstanceID,getdate(),@Usercode,a.docdate,a.formid,5,a.companyid,a.cnt,b.cnt,'ҵ��������һ��.'
				  from cte a full join cte1 b on a.formid=b.formid and a.docdate=b.docdate and a.companyid=b.companyid
				where isnull(a.cnt,0)<>isnull(b.cnt,0)
			END
		--У��imatdoc_h��imatdoc_d��
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
				select @TaskID,@TaskInstanceID,getdate(),@Usercode,a.docdate,a.formid,5,a.companyid,a.cnt,b.cnt,'ҵ��������һ��.'
				  from cte a full join cte1 b on a.formid=b.formid and a.docdate=b.docdate and a.companyid=b.companyid
				where isnull(a.cnt,0)<>isnull(b.cnt,0)
			END
			--У��iseriesloghd��iserieslogitem��
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
				select @TaskID,@TaskInstanceID,getdate(),@Usercode,a.docdate,a.formid,5,a.companyid,a.cnt,b.cnt,'ҵ��������һ��.'
				  from cte a full join cte1 b on a.formid=b.formid and a.docdate=b.docdate and a.companyid=b.companyid
				where isnull(a.cnt,0)<>isnull(b.cnt,0)
			END
			--У��sPickorderHD��sPickrderitem��
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
					select @TaskID,@TaskInstanceID,getdate(),@Usercode,a.docdate,a.formid,5,a.companyid,a.cnt,b.cnt,'ҵ��������һ��.'
					  from cte a full join cte1 b on a.formid=b.formid and a.docdate=b.docdate and a.companyid=b.companyid
					where isnull(a.cnt,0)<>isnull(b.cnt,0)
				END

		return
	END
 