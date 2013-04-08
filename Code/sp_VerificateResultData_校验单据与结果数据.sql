/*
��������:sp_VerificateResultData
��������:У�鵥���������������Ƿ�һ��,ֻУ�������Ƿ�һ��
����:������
��д:���ϵ�
ʱ��:2013-04-02
��ע:
ʾ��:exec sp_VerificateResultData '','2013-02-1','2013-02-1','1501,1504,1507,1509,1512,1520,1598,1599,1512,4061,4062'
exec sp_VerificateResultData '','2013-01-1','2013-01-30','2137'
exec sp_VerificateResultData '','2013-03-27','2013-03-27','2419,2420,2450,2401,2418,4031,4032,4950,4951,4954,2424'
*/
  --select * from DataVerificationLog dvl where formid in(2137) 
  -- select * from DataVerificationLog dvl where formid in(2419,2420,2450,2401,2418,4031,4032,4950,4951,4954,2424) 
   -- delete from DataVerificationLog
alter proc sp_VerificateResultData
	@TaskID varchar(50),										--����ID,�ȴ���
	@BeginDate DATETIME,									--��ʼʱ��
	@EndDate datetime,										--����ʱ��
	@FormIDList varchar(200)='',							--���ܺ��б�
	@CompanyIDList varchar(200)='',					--��˾�б�
	@SDOrgList varchar(500)='',							--�����б�
	@StcodeList varchar(500)='',							--�ֿ��б�
	@DoccodeList varchar(500)='',						--�����б�
	@Remark varchar(500)='',								--��ע
	@Usercode varchar(30)='',								--�û�
	@TerminalID varchar(50)=''								--�ն�
as
	BEGIN
		set NOCOUNT ON
		declare @TaskInstanceID varchar(50)
		select @TaskInstanceID=newid()
		--��ɾ������Ҫ��������
		delete a from DataVerificationLog a
		where (@CompanyIDList='' or exists(select 1 from commondb.dbo.SPLIT(@CompanyIDList,',') s where s.List in(a.CompanyID, a.companyid2)))
					and (@FormIDList='' or exists(select 1 from commondb.dbo.SPLIT(@FormIDList,',') s where s.List =a.FormID))
					and (@DoccodeList='' or exists(select 1 from commondb.dbo.SPLIT(@DoccodeList,',') s where s.List in(a.DocCode,a.doccode2)))
					and (@StcodeList='' or exists(select 1 from commondb.dbo.SPLIT(@StcodeList,',') s where s.List in(a.stcode,a.stcode2)))
					and (@SDOrgList='' or exists(select 1 from commondb.dbo.SPLIT(@SDOrgList,',') s where s.List in(a.sdorgid,a.sdorgid2)))
					and a.DocDate between @BeginDate and @EndDate
		--@TaskID=1	����鵥����ҵ����Ƿ�һ��,���ָ�����ܺŵ����������Ƿ�һ��
		--У��Commsales_h��Commsales_d��
		if @FormIDList='' or exists(select 1 from commondb.dbo.split(@FormIDList,',') s where s.List in(4630,4631))
			BEGIN
				with cte as(
					select a.FormID,a.companyid,a.DocDate,count(*) as cnt,sum(isnull(b.Digit,0)) as digit,sum(isnull(b.totalmoney,0)) as totalmoney
					  from Commsales_h  a with(nolock) inner join Commsales_d b with(nolock) on a.DocCode=b.DocCode
					  inner join gform g with(nolock) on a.FormID=g.formid
					where (@CompanyIDList='' or exists(select 1 from commondb.dbo.SPLIT(@CompanyIDList,',') s where s.List=a.CompanyID))
					and (@FormIDList='' or exists(select 1 from commondb.dbo.SPLIT(@FormIDList,',') s where s.List=a.FormID))
					and (@DoccodeList='' or exists(select 1 from commondb.dbo.SPLIT(@DoccodeList,',') s where s.List=a.DocCode))
					and (@StcodeList='' or exists(select 1 from commondb.dbo.SPLIT(@StcodeList,',') s where s.List=a.stcode))
					and (@SDOrgList='' or exists(select 1 from commondb.dbo.SPLIT(@SDOrgList,',') s where s.List=a.sdorgid))
					and a.DocDate between @BeginDate and @EndDate
					and a.formid in(4630,4631)
					and a.DocStatus=g.postdocstatus
					group by a.FormID,a.companyid,a.DocDate
					),
				cte1 as(
					select a.FormID,a.companyid,a.DocDate,count(*) cnt,sum(isnull(a.Digit,0)) as digit,sum(isnull(a.TotalMoney,0)) as totalmoney
					from jturp.dbo.SOP_FACT_ALL_BUSINESS a with(nolock)
						where (@CompanyIDList='' or exists(select 1 from commondb.dbo.SPLIT(@CompanyIDList,',') s where s.List=a.CompanyID))
						and (@FormIDList='' or exists(select 1 from commondb.dbo.SPLIT(@FormIDList,',') s where s.List=a.FormID))
						and (@DoccodeList='' or exists(select 1 from commondb.dbo.SPLIT(@DoccodeList,',') s where s.List=a.DocCode))
						and (@StcodeList='' or exists(select 1 from commondb.dbo.SPLIT(@StcodeList,',') s where s.List=a.stcode))
						and (@SDOrgList='' or exists(select 1 from commondb.dbo.SPLIT(@SDOrgList,',') s where s.List=a.sdorgid))
						and a.DocDate between @BeginDate and @EndDate
						and a.formid in(4630,4631)
						group by a.FormID,a.companyid,a.DocDate
					)
				insert into DataVerificationLog(TaskID,TaskInstanceID,OperDate,OperName,DocDate,FormID,FormType,companyid,Digit,Digit2, Remark,COMPANYID2)
				select @TaskID,@TaskInstanceID,getdate(),@Usercode,isnull(a.docdate,b.docdate),isnull(a.formid,b.formid),5,a.companyid,a.cnt,b.cnt,'ҵ��������һ��.',b.companyid
				  from cte a full join cte1 b on a.formid=b.formid and a.docdate=b.docdate and a.companyid=b.companyid
				where isnull(a.cnt,0)<>isnull(b.cnt,0)
			END
		--У��imatdoc_h��imatdoc_d��
		if @FormIDList='' or exists(select 1 from commondb.dbo.split(@FormIDList,',') s where s.List in(1501,1504,1507,1509,1512,1520,1523,1598,1599,4061,4062))
			BEGIN
				with cte as(
					select a.FormID,a.companyid,a.DocDate,count(*) as cnt ,sum(isnull(b.Digit,0)) as digit,sum(isnull(b.totalmoney,0)) as totalmoney
					  from imatdoc_h  a with(nolock) inner join imatdoc_d b with(nolock) on a.DocCode=b.DocCode
					  inner join gform g with(nolock) on a.FormID=g.formid
					where (@CompanyIDList='' or exists(select 1 from commondb.dbo.SPLIT(@CompanyIDList,',') s where s.List=a.CompanyID))
					and (@FormIDList='' or exists(select 1 from commondb.dbo.SPLIT(@FormIDList,',') s where s.List=a.FormID))
					and (@DoccodeList='' or exists(select 1 from commondb.dbo.SPLIT(@DoccodeList,',') s where s.List=a.DocCode))
					and (@StcodeList='' or exists(select 1 from commondb.dbo.SPLIT(@StcodeList,',') s where s.List=a.stcode))
					and (@SDOrgList='' or exists(select 1 from commondb.dbo.SPLIT(@SDOrgList,',') s where s.List=a.sdorgid))
					and a.DocDate between @BeginDate and @EndDate
					and a.formid in(1501,1504,1507,1509,1512,1520,1523,1598,1599,4061,4062)
					and a.DocStatus=g.postdocstatus
					group by a.FormID,a.companyid,a.DocDate
					),
				cte1 as(
					select a.FormID,a.companyid,a.DocDate,count(*) cnt,sum(isnull(a.Digit,0)) as digit,sum(isnull(a.TotalMoney,0)) as totalmoney
					from jturp.dbo.SOP_FACT_ALL_BUSINESS a with(nolock)
						where (@CompanyIDList='' or exists(select 1 from commondb.dbo.SPLIT(@CompanyIDList,',') s where s.List=a.CompanyID))
						and (@FormIDList='' or exists(select 1 from commondb.dbo.SPLIT(@FormIDList,',') s where s.List=a.FormID))
						and (@DoccodeList='' or exists(select 1 from commondb.dbo.SPLIT(@DoccodeList,',') s where s.List=a.DocCode))
						and (@StcodeList='' or exists(select 1 from commondb.dbo.SPLIT(@StcodeList,',') s where s.List=a.stcode))
						and (@SDOrgList='' or exists(select 1 from commondb.dbo.SPLIT(@SDOrgList,',') s where s.List=a.sdorgid))
						and a.DocDate between @BeginDate and @EndDate
						and a.formid in(1501,1504,1507,1509,1512,1520,1523,1598,1599,4061,4062)
						group by a.FormID,a.companyid,a.DocDate
					)
				insert into DataVerificationLog(TaskID,TaskInstanceID,OperDate,OperName,DocDate,FormID,FormType,companyid,Digit,Digit2, Remark,COMPANYID2)
				select @TaskID,@TaskInstanceID,getdate(),@Usercode,isnull(a.docdate,b.docdate),isnull(a.formid,b.formid),5,a.companyid,a.cnt,b.cnt,'ҵ��������һ��.',b.companyid
				  from cte a full join cte1 b on a.formid=b.formid and a.docdate=b.docdate and a.companyid=b.companyid
				where isnull(a.cnt,0)<>isnull(b.cnt,0)
			END
			--У��iseriesloghd��iserieslogitem��
			if @FormIDList='' or exists(select 1 from commondb.dbo.split(@FormIDList,',') s where s.List in(1553,1557))
			BEGIN
				with cte as(
					select a.FormID,a.companyid,a.DocDate,count(*) as cnt ,0 as digit,sum(isnull(b.totalmoney,0)) as totalmoney
					from iseriesloghd   a with(nolock) inner join iserieslogitem  b with(nolock) on a.DocCode=b.DocCode
					inner join gform g with(nolock) on a.FormID=g.formid
					where (@CompanyIDList='' or exists(select 1 from commondb.dbo.SPLIT(@CompanyIDList,',') s where s.List=a.CompanyID))
					and (@FormIDList='' or exists(select 1 from commondb.dbo.SPLIT(@FormIDList,',') s where s.List=a.FormID))
					and (@DoccodeList='' or exists(select 1 from commondb.dbo.SPLIT(@DoccodeList,',') s where s.List=a.DocCode))
					and (@StcodeList='' or exists(select 1 from commondb.dbo.SPLIT(@StcodeList,',') s where s.List=a.stcode))
					and (@SDOrgList='' or exists(select 1 from commondb.dbo.SPLIT(@SDOrgList,',') s where s.List=a.sdorgid))
					and a.DocDate between @BeginDate and @EndDate
					and a.formid in(1553,1557)
					and a.DocStatus=g.postdocstatus
					group by a.FormID,a.companyid,a.DocDate
					),
				cte1 as(
					select a.FormID,a.companyid,a.DocDate,count(*) cnt,sum(isnull(a.Digit,0)) as digit,sum(isnull(a.totalmoney,0)) as totalmoney
					from jturp.dbo.SOP_FACT_ALL_BUSINESS a with(nolock)
						where (@CompanyIDList='' or exists(select 1 from commondb.dbo.SPLIT(@CompanyIDList,',') s where s.List=a.CompanyID))
						and (@FormIDList='' or exists(select 1 from commondb.dbo.SPLIT(@FormIDList,',') s where s.List=a.FormID))
						and (@DoccodeList='' or exists(select 1 from commondb.dbo.SPLIT(@DoccodeList,',') s where s.List=a.DocCode))
						and (@StcodeList='' or exists(select 1 from commondb.dbo.SPLIT(@StcodeList,',') s where s.List=a.stcode))
						and (@SDOrgList='' or exists(select 1 from commondb.dbo.SPLIT(@SDOrgList,',') s where s.List=a.sdorgid))
						and a.DocDate between @BeginDate and @EndDate
						and a.formid in(1553,1557)
						group by a.FormID,a.companyid,a.DocDate
					)
				insert into DataVerificationLog(TaskID,TaskInstanceID,OperDate,OperName,DocDate,FormID,FormType,companyid,Digit,Digit2, Remark,COMPANYID2)
				select @TaskID,@TaskInstanceID,getdate(),@Usercode,isnull(a.docdate,b.docdate),isnull(a.formid,b.formid),5,a.companyid,a.cnt,b.cnt,'ҵ��������һ��.',b.companyid
				  from cte a full join cte1 b on a.formid=b.formid and a.docdate=b.docdate and a.companyid=b.companyid
				where isnull(a.cnt,0)<>isnull(b.cnt,0)
			END
			--У��sPickorderHD��sPickrderitem��
			if @FormIDList='' or exists(select 1 from commondb.dbo.split(@FormIDList,',') s where s.List in(2401,2418,2419,2420,2424,2450,4031,4032,4950,4951))
				BEGIN
					with cte as(
						select a.FormID,a.companyid,a.DocDate,count(*) as cnt ,count(*) as digit,sum(isnull(b.totalmoney,0)) as totalmoney
						from sPickorderHD    a with(nolock) inner join sPickorderitem  b with(nolock) on a.DocCode=b.DocCode
						inner join gform g with(nolock) on a.FormID=g.formid
						where (@CompanyIDList='' or exists(select 1 from commondb.dbo.SPLIT(@CompanyIDList,',') s where s.List=a.CompanyID))
						and (@FormIDList='' or exists(select 1 from commondb.dbo.SPLIT(@FormIDList,',') s where s.List=a.FormID))
						and (@DoccodeList='' or exists(select 1 from commondb.dbo.SPLIT(@DoccodeList,',') s where s.List=a.DocCode))
						and (@StcodeList='' or exists(select 1 from commondb.dbo.SPLIT(@StcodeList,',') s where s.List=a.stcode))
						and (@SDOrgList='' or exists(select 1 from commondb.dbo.SPLIT(@SDOrgList,',') s where s.List=a.sdorgid))
						and a.DocDate between @BeginDate and @EndDate
						and (1=case when a.formid=2424  and a.feedbackmemo is null then 0 
											when a.formid=4031 and a.zpdoc  is null then 0
											when a.formid=4032 and a.refcode is null then 0
											else 1
									end)
						and a.formid in(2401,2418,2419,2420,2424,2450,4031,4032,4950,4951)
						and a.DocStatus=g.postdocstatus
						group by a.FormID,a.companyid,a.DocDate
						),
					cte1 as(
						select a.FormID,a.companyid,a.DocDate,count(*) cnt,sum(isnull(a.Digit,0)) as digit,sum(isnull(a.TotalMoney,0)) as totalmoney
						from jturp.dbo.SOP_FACT_ALL_BUSINESS a with(nolock)
							where (@CompanyIDList='' or exists(select 1 from commondb.dbo.SPLIT(@CompanyIDList,',') s where s.List=a.CompanyID))
							and (@FormIDList='' or exists(select 1 from commondb.dbo.SPLIT(@FormIDList,',') s where s.List=a.FormID))
							and (@DoccodeList='' or exists(select 1 from commondb.dbo.SPLIT(@DoccodeList,',') s where s.List=a.DocCode))
							and (@StcodeList='' or exists(select 1 from commondb.dbo.SPLIT(@StcodeList,',') s where s.List=a.stcode))
							and (@SDOrgList='' or exists(select 1 from commondb.dbo.SPLIT(@SDOrgList,',') s where s.List=a.sdorgid))
							and a.DocDate between @BeginDate and @EndDate
							and a.formid in(2401,2418,2419,2420,2424,2450,4031,4032,4950,4951)
							group by a.FormID,a.companyid,a.DocDate
						)
					insert into DataVerificationLog(TaskID,TaskInstanceID,OperDate,OperName,DocDate,FormID,FormType,companyid,Digit,Digit2, Remark,COMPANYID2)
					select @TaskID,@TaskInstanceID,getdate(),@Usercode,isnull(a.docdate,b.docdate),isnull(a.formid,b.formid),5,a.companyid,a.cnt,b.cnt,'ҵ��������һ��.',b.companyid
					  from cte a full join cte1 b on a.formid=b.formid and a.docdate=b.docdate and a.companyid=b.companyid
					where isnull(a.cnt,0)<>isnull(b.cnt,0)
				END
			--У��sPickorderHD��sPickrderitem��
			if @FormIDList='' or exists(select 1 from commondb.dbo.split(@FormIDList,',') s where s.List in(2137,2941))
				BEGIN
					with cte as(
						select a.FormID,case when a.formid=2137 then os.PlantID else    a.companyid end as companyid,a.DocDate,
						count(*) as cnt ,sum(isnull(b.Digit,0)) as digit,sum(isnull(b.totalmoney,0)) as totalmoney
						from MObileAssurehd   a with(nolock) inner join MObileAssureitem   b with(nolock) on a.DocCode=b.DocCode
						left join oStorage os with(nolock) on os.stcode=b.stcode
						inner join gform g with(nolock) on a.FormID=g.formid
						where (@CompanyIDList='' or exists(select 1 from commondb.dbo.SPLIT(@CompanyIDList,',') s where s.List=a.CompanyID))
						and (@FormIDList='' or exists(select 1 from commondb.dbo.SPLIT(@FormIDList,',') s where s.List=a.FormID))
						and (@DoccodeList='' or exists(select 1 from commondb.dbo.SPLIT(@DoccodeList,',') s where s.List=a.DocCode))
						and (@StcodeList='' or exists(select 1 from commondb.dbo.SPLIT(@StcodeList,',') s where s.List=a.stcode))
						and (@SDOrgList='' or exists(select 1 from commondb.dbo.SPLIT(@SDOrgList,',') s where s.List=a.sdorgid))
						and a.DocDate between @BeginDate and @EndDate
						and a.formid in(2137,2941)
						and a.DocStatus=g.postdocstatus
						group by a.FormID,case when a.formid=2137 then os.PlantID else    a.companyid end,a.DocDate
						),
					cte1 as(
						select a.FormID,a.companyid,a.DocDate,count(*) cnt,sum(isnull(a.Digit,0)) as digit,sum(isnull(a.TotalMoney,0)) as totalmoney
						from jturp.dbo.SOP_FACT_ALL_BUSINESS a with(nolock)
							where (@CompanyIDList='' or exists(select 1 from commondb.dbo.SPLIT(@CompanyIDList,',') s where s.List=a.CompanyID))
							and (@FormIDList='' or exists(select 1 from commondb.dbo.SPLIT(@FormIDList,',') s where s.List=a.FormID))
							and (@DoccodeList='' or exists(select 1 from commondb.dbo.SPLIT(@DoccodeList,',') s where s.List=a.DocCode))
							and (@StcodeList='' or exists(select 1 from commondb.dbo.SPLIT(@StcodeList,',') s where s.List=a.stcode))
							and (@SDOrgList='' or exists(select 1 from commondb.dbo.SPLIT(@SDOrgList,',') s where s.List=a.sdorgid))
							and a.DocDate between @BeginDate and @EndDate
							and a.formid in(2137,2941)
							group by a.FormID,a.companyid,a.DocDate
						)
					insert into DataVerificationLog(TaskID,TaskInstanceID,OperDate,OperName,DocDate,FormID,FormType,companyid,Digit,Digit2, Remark,COMPANYID2)
					select @TaskID,@TaskInstanceID,getdate(),@Usercode,isnull(a.docdate,b.docdate),isnull(a.formid,b.formid),5,a.companyid,a.cnt,b.cnt,'ҵ��������һ��.',b.companyid
					  from cte a full join cte1 b on a.formid=b.formid and a.docdate=b.docdate and a.companyid=b.companyid
					where isnull(a.cnt,0)<>isnull(b.cnt,0)
				END
		return
	END
 