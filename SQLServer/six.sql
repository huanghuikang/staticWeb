USE [ekp]
GO
/****** Object:  StoredProcedure [dbo].[tongjiTFCLjianshu]    Script Date: 2018/11/14 14:46:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[tongjiTFCLjianshu]

AS
BEGIN

	SET NOCOUNT ON;
	--创建表用于对超时完成，超时末完成和按时完成统计
	create table #table2
	(
		fd_id varchar(200),
		fd_name varchar(100),
		fd_node_anme varchar(100),
		fd_node_allnum int,
		fd_cost_time decimal(18,2),
		fd_flow_status int
	)
	insert #table2
	--个人处理的节点，时间和状态
	select t4.fd_id,t4.fd_name,t2.fd_fact_node_name,t5.fd_node_allnum,t1.fd_cost_time/240000 fd_cost_time,t3.fd_flow_status
	 from lbpm_history_workitem t1
	inner join lbpm_audit_note t2 on t2.fd_node_id=t1.fd_node_id
	inner join sys_org_element t4 on t4.fd_id=t2.fd_handler_id
	inner join db_flowstat_flow_doc t3 on t3.fd_main_doc_id=t1.fd_process_id
	inner join 
	(
		select t1.fd_handler_id,count(t1.fd_node_id) fd_node_allnum from lbpm_history_workitem t1
		inner join sys_org_element t3 on t3.fd_id=t1.fd_handler_id
		group by fd_handler_id 
	) t5 on t5.fd_handler_id=t4.fd_id
	where t2.fd_fact_node_name not like '起草'
	--select * from #table2
	select fd_id,
		count(case  when fd_cost_time > 4 then fd_node_allnum end) 超时末完成,
		count(case  when fd_cost_time < 4 then fd_node_allnum end) 超时完成
		
	from #table2
	group by fd_id
	drop table #table2


	create table #table1
	(
		fd_name varchar(200),

	)
		select t3.fd_name 办件人,t4.fd_node_allnum 办件总数,t6.fd_nofin_allnum 末完成数,t2.fd_fact_node_name 节点名,
		t1.fd_cost_time/240000 审批耗时,t5.fd_flow_status 节点状态 from lbpm_history_workitem t1
		inner join lbpm_audit_note t2 on t2.fd_node_id=t1.fd_node_id
		inner join sys_org_element t3 on t3.fd_id=t1.fd_handler_id
		inner join (
		select t1.fd_handler_id,count(t1.fd_node_id) fd_node_allnum from lbpm_history_workitem t1
		inner join sys_org_element t3 on t3.fd_id=t1.fd_handler_id
		group by fd_handler_id
		--order by fd_node_allnum
		) t4 on t4.fd_handler_id=t3.fd_id
		inner join db_flowstat_flow_doc t5 on t5.fd_main_doc_id=t1.fd_process_id
		inner join 
		(
		select t1.fd_handler_id,count(t1.fd_node_id) fd_nofin_allnum from lbpm_history_workitem t1
		inner join sys_org_element t3 on t3.fd_id=t1.fd_handler_id
		inner join db_flowstat_flow_doc t5 on t5.fd_main_doc_id=t1.fd_process_id
		where t5.fd_flow_status <> 4
		group by fd_handler_id
		--order by fd_node_allnum
		) t6 on t6.fd_handler_id=t4.fd_handler_id
		where t2.fd_fact_node_name not like '起草'
