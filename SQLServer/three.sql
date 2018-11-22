USE [ekp]
GO
/****** Object:  StoredProcedure [dbo].[gerenxiaoshounew]    Script Date: 11/07/2018 11:26:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[gerenxiaoshounew] 
(
	@fd_beginTime varchar(100) ,
	@fd_endTime varchar(100),
	@fd_baoxiaoren varchar(255)
)
AS
BEGIN
	SET NOCOUNT ON;
	
	
	create table #yg_pay_sum
		(
		fd_id varchar(200),
		jine decimal(18,2),
		text1 varchar(255)
		)

		insert #yg_pay_sum
		select t4.fd_id,sum(isnull(t1.fd_jinE,0)) as jine,t1.fd_365662c47e4e56_text from ekp_baoxiaomingxi t1
		inner join
		ekp_gerenbaoxiao  t2 on t2.fd_id=t1.fd_parent_id
		inner join
		ekporg_feiyongPost t3 on t3.fd_parent_id=t2.fd_id
		inner join              
		sys_org_element t4 on t4.fd_id=t2.fd_baoXiaoRen
		where 1=1 and isnull(t1.fd_365662c47e4e56_text,'')<>''
		AND 1 = CASE WHEN ISNULL(@fd_beginTime, '') = '' THEN 1
            ELSE CASE WHEN t2.fd_baoXiaoRiQi>=@fd_beginTime
                THEN 1
                ELSE 0
            END
        END
        AND 1 = CASE WHEN ISNULL(@fd_endTime, '') = '' THEN 1
            ELSE CASE WHEN t2.fd_baoXiaoRiQi<=@fd_endTime
                THEN 1
                ELSE 0
            END
        END
		AND 1 = CASE WHEN ISNULL(@fd_baoxiaoren, '') = '' THEN 1
			ELSE CASE WHEN ISNULL(t4.fd_name, '') = @fd_baoxiaoren
				THEN 1
				ELSE 0
			END
        END
		group by t4.fd_id,t1.fd_365662c47e4e56_text 

		update #yg_pay_sum set text1=REPLACE(text1,'-','')
		update #yg_pay_sum set text1=REPLACE(text1,'（','')
		update #yg_pay_sum set text1=REPLACE(text1,'）','') 
		update #yg_pay_sum set text1=REPLACE(text1,'、','') 

		--行转列的实现
		DECLARE @sql varchar(8000),
				@sqlname VARCHAR(8000)

        SELECT @sqlname=isnull(@sqlname+',','')+text1 FROM #yg_pay_sum GROUP BY text1 

		set @sqlname=REPLACE(@sqlname,'-','')
		set @sqlname=REPLACE(@sqlname,'（','')
		set @sqlname=REPLACE(@sqlname,'）','')
		set @sqlname=REPLACE(@sqlname,'、','')



		--select @sqlname

		set @sql='select cast(0 as decimal(18,2)) as sumjine,* into yg_pay_sumth from #yg_pay_sum as P pivot(sum(jine) for p.text1 in ('+@sqlname+')) as T'
		--print(@sql)
		exec(@sql)

		update a set a.sumjine=b.jine from yg_pay_sumth a
		inner join 
		(select fd_id,sum(jine) as jine from #yg_pay_sum group by fd_id) b on b.fd_id=a.fd_id

		declare @sqlstr varchar(8000)


		set @sqlstr='select RANK() OVER(ORDER BY b.fd_name) AS 序号,b.fd_name as 姓名,a.sumjine as 总计,'+@sqlname+' from yg_pay_sumth a inner join sys_org_element b on a.fd_id=b.fd_id '
		exec(@sqlstr)


		drop table yg_pay_sumth
		drop table #yg_pay_sum


end
