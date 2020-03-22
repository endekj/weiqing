-- phpMyAdmin SQL Dump
-- version phpStudy 2014
-- http://www.phpmyadmin.net
--
-- 主机: localhost
-- 生成日期: 2019 �?08 �?20 �?08:23
-- 服务器版本: 5.5.53
-- PHP 版本: 5.6.27

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- 数据库: `root`
--

DELIMITER $$
--
-- 存储过程
--
CREATE DEFINER=`b`@`localhost` PROCEDURE `addScore`(`_uid` INT, `_amount` FLOAT)
begin
	
	declare bonus float;
	select `value` into bonus from ssc_params where name='scoreProp' limit 1;
	
	set bonus=bonus*_amount;
	
	if bonus then
		update ssc_members u, ssc_params p set u.score = u.score+bonus, u.scoreTotal=u.scoreTotal+bonus where u.`uid`=_uid;
	end if;
	
end$$

CREATE DEFINER=`b`@`localhost` PROCEDURE `auto_clearData`()
begin

	declare endDate int;
	set endDate = UNIX_TIMESTAMP(now())-7*24*3600;

	
	delete from ssc_data where time < endDate;
	
	delete from ssc_member_session where accessTime < endDate;
	
	delete from ssc_bets where kjTime < endDate and lotteryNo <> '';
	

	delete from ssc_admin_log where actionTime < endDate;

end$$

CREATE DEFINER=`b`@`localhost` PROCEDURE `betcount`(`_date` INT(8), `_type` TINYINT(3), `_uid` INT(10))
begin
  
	declare _pri int(11) DEFAULT 0; 
	declare _betCount int(5) DEFAULT 0;
	declare _betAmount double(15,4) DEFAULT 0.0000;
	declare _betAmountb double(15,4) DEFAULT 0.0000;
	declare _zjAmount double(15,4) DEFAULT 0.0000;
	declare _rebateMoney double(15,4) DEFAULT 0.0000;
	declare _username VARCHAR(16) DEFAULT null;
	declare _gudongId int(10) DEFAULT 0; 
	declare _zparentId int(10) DEFAULT 0; 
	declare _parentId int(10) DEFAULT 0; 

	select uid into _uid from ssc_members where isDelete=0 and `uid`=_uid;
	if _uid then

	select id into _pri from ssc_count where `date`=_date and `uid`=_uid and `type`=_type  LIMIT 1;

	if _pri=0 or _pri is null THEN
		insert into ssc_count (`date`, `uid`, `type`) values(_date, _uid, _type);
		select id into _pri from ssc_count where date=_date and `uid`=_uid and `type`=_type LIMIT 1;
	end if;




	select count(*) into _betCount from ssc_bets where isDelete=0 and `uid`=_uid and `lotteryNo` !='' and `type` =_type and FROM_UNIXTIME(kjTime,'%Y%m%d') = _date;
	

	select sum(totalMoney) into _betAmount from ssc_bets where isDelete=0 and `uid` =_uid and `lotteryNo` !='' and `type` =_type and `betInfo` !='' and `totalNums` >1 and `totalMoney` >0 and FROM_UNIXTIME(kjTime,'%Y%m%d') = _date;

	select sum(money) into _betAmountb from ssc_bets where isDelete=0 and `uid` =_uid and `lotteryNo` !='' and `type` =_type and `totalNums` =1 and `totalMoney` =0 and FROM_UNIXTIME(kjTime,'%Y%m%d') = _date;


	select sum(bonus) into _zjAmount from ssc_bets where isDelete=0 and `uid` =_uid and `lotteryNo` !='' and `type` =_type and FROM_UNIXTIME(kjTime,'%Y%m%d') = _date;

	select sum(rebateMoney) into _rebateMoney from ssc_bets where isDelete=0 and `uid` =_uid and `lotteryNo` !='' and `type` =_type and FROM_UNIXTIME(kjTime,'%Y%m%d') = _date;
	

	select username into _username from ssc_members where isDelete=0 and `uid` =_uid;
	select gudongId into _gudongId from ssc_members where isDelete=0 and `uid` =_uid;
	select zparentId into _zparentId from ssc_members where isDelete=0 and `uid` =_uid;	
	select parentId into _parentId from ssc_members where isDelete=0 and `uid` =_uid;



	if _betCount is null THEN
		set _betCount = 0;
	end if;

	if _betAmount is null THEN
		set _betAmount = 0;
	end if;
	if _betAmountb is null THEN
		set _betAmountb = 0;
	end if;
	if _zjAmount is null THEN
		set _zjAmount = 0;
	end if;
	if _rebateMoney is null THEN
		set _rebateMoney = 0;
	end if;
	
	set _betAmount = _betAmount + _betAmountb;

	update ssc_count set betCount=_betCount, betAmount=_betAmount, zjAmount=_zjAmount, rebateMoney=_rebateMoney, username=_username, uid=_uid, gudongId=_gudongId, zparentId=_zparentId, parentId=_parentId where id=_pri;	

	end if;

end$$

CREATE DEFINER=`b`@`localhost` PROCEDURE `betreport`(`_date` INT(8), `_uid` INT(10))
begin
 
	declare _pri int(11) DEFAULT 0; 
	declare _betCount int(5) DEFAULT 0;
	declare _betAmount double(15,4) DEFAULT 0.0000;
	declare _betAmountb double(15,4) DEFAULT 0.0000;
	declare _zjAmount double(15,4) DEFAULT 0.0000;
	declare _rebateMoney double(15,4) DEFAULT 0.0000;
	declare _username VARCHAR(16) DEFAULT null;
	declare _gudongId int(10) DEFAULT 0; 
	declare _zparentId int(10) DEFAULT 0; 
	declare _parentId int(10) DEFAULT 0; 

	select uid into _uid from ssc_members where isDelete=0 and uid=_uid;
	if _uid then

	select id into _pri from ssc_report where date=_date and uid=_uid LIMIT 1;
	
	if _pri=0 or _pri is null THEN
		insert into ssc_report (date, uid) values(_date, _uid);
		select id into _pri from ssc_report where date=_date and uid=_uid LIMIT 1;
	end if;




	select count(*) into _betCount from ssc_bets where isDelete=0 and uid=_uid and lotteryNo!='' and FROM_UNIXTIME(kjTime,'%Y%m%d') = _date;

	select sum(totalMoney) into _betAmount from ssc_bets where isDelete=0 and uid=_uid and lotteryNo!='' and betInfo!='' and totalNums>1 and totalMoney>0 and FROM_UNIXTIME(kjTime,'%Y%m%d') = _date;

	select sum(money) into _betAmountb from ssc_bets where isDelete=0 and uid=_uid and lotteryNo!='' and totalNums=1 and totalMoney=0 and FROM_UNIXTIME(kjTime,'%Y%m%d') = _date;

	select sum(bonus) into _zjAmount from ssc_bets where isDelete=0 and uid=_uid and lotteryNo!='' and FROM_UNIXTIME(kjTime,'%Y%m%d') = _date;

	select sum(rebateMoney) into _rebateMoney from ssc_bets where isDelete=0 and uid=_uid and lotteryNo!='' and FROM_UNIXTIME(kjTime,'%Y%m%d') = _date;
	
	
	select username into _username from ssc_members where isDelete=0 and uid=_uid;
	select gudongId into _gudongId from ssc_members where isDelete=0 and uid=_uid;
	select zparentId into _zparentId from ssc_members where isDelete=0 and uid=_uid;	
	select parentId into _parentId from ssc_members where isDelete=0 and uid=_uid;



	if _betCount is null THEN
		set _betCount = 0;
	end if;

	if _betAmount is null THEN
		set _betAmount = 0;
	end if;
	if _betAmountb is null THEN
		set _betAmountb = 0;
	end if;
	if _zjAmount is null THEN
		set _zjAmount = 0;
	end if;
	if _rebateMoney is null THEN
		set _rebateMoney = 0;
	end if;
	
	set _betAmount = _betAmount + _betAmountb;

	update ssc_report set betCount=_betCount, betAmount=_betAmount, zjAmount=_zjAmount, rebateMoney=_rebateMoney, username=_username, uid=_uid, gudongId=_gudongId, zparentId=_zparentId, parentId=_parentId where id=_pri;
	end if;

end$$

CREATE DEFINER=`b`@`localhost` PROCEDURE `cancelBet`(`_zhuiHao` VARCHAR(255))
begin

	declare amount float;
	declare _uid int;
	declare _id int;
	declare _type int;
	
	declare info varchar(255) character set utf8;
	declare liqType int default 5;
	
	declare done int default 0;
	declare cur cursor for
	select id, money, `uid`, `type` from ssc_bets where serializeId=_zhuiHao and lotteryNo='' and isDelete=0;
	declare continue HANDLER for not found set done=1;
	
	open cur;
		repeat
			fetch cur into _id, amount, _uid, _type;
			if not done then
				update ssc_bets set isDelete=1 where id=_id;
				set info='追号撤单';
				call setCoin(amount, 0, _uid, liqType, _type, info, _id, '', '');
			end if;
		until done end repeat;
	close cur;

end$$

CREATE DEFINER=`b`@`localhost` PROCEDURE `clearData`(`dateInt` INT(11))
begin

	declare endDate int;
	set endDate = dateInt;
	

	
	delete from ssc_bets where kjTime < endDate and lotteryNo <> '';
	
	
	delete from ssc_count where `date` < FROM_UNIXTIME(endDate,'%Y-%m-%d');
	delete from ssc_report where `date` < FROM_UNIXTIME(endDate,'%Y-%m-%d');
end$$

CREATE DEFINER=`b`@`localhost` PROCEDURE `clearData2`(`dateInt` INT(11))
begin

	declare endDate int;
	set endDate = dateInt;

	
	delete from ssc_data where time < endDate;

end$$

CREATE DEFINER=`b`@`localhost` PROCEDURE `clearData3`(`dateInt` INT(11))
begin

	declare endDate int;
	set endDate = dateInt;
	
	
	delete from ssc_coin_log where actionTime < endDate;
		
	
end$$

CREATE DEFINER=`b`@`localhost` PROCEDURE `clearData4`(`dateInt` INT(11))
begin

	declare endDate int;
	set endDate = dateInt;
	
	

	delete from ssc_admin_log where actionTime < endDate;
	
end$$

CREATE DEFINER=`b`@`localhost` PROCEDURE `clearData5`(`dateInt` INT(11))
begin

	declare endDate int;
	set endDate = dateInt;
	
	
	delete from ssc_member_session where accessTime < endDate;
	
end$$

CREATE DEFINER=`b`@`localhost` PROCEDURE `clearData6`(`dateInt` INT(11))
begin

	declare endDate int;
	set endDate = dateInt;
	
	
	delete from ssc_member_cash where actionTime < endDate and state <> 1;
	
end$$

CREATE DEFINER=`b`@`localhost` PROCEDURE `clearData7`(`dateInt` INT(11))
begin

	declare endDate int;
	set endDate = dateInt;
	
	

	delete from ssc_member_recharge where actionTime < endDate and state <> 0;
	delete from ssc_member_recharge where actionTime < endDate-24*3600 and state = 0;
	
end$$

CREATE DEFINER=`b`@`localhost` PROCEDURE `conComAll`(`baseAmount` FLOAT, `parentAmount` FLOAT, `parentLevel` INT)
begin

	declare conUid int;
	declare conUserName varchar(255);
	declare tjAmount float;
	declare done int default 0;	
	declare dateTime int default unix_timestamp(curdate());

	declare cur cursor for
	select b.uid, b.username, sum(b.money) _tjAmount from ssc_bets b where b.kjTime>=dateTime and b.uid not in(select distinct l.extfield0 from ssc_coin_log l where l.liqType=53 and l.actionTime>=dateTime and l.extfield2=parentLevel) group by b.uid having _tjAmount>=baseAmount;
	declare continue HANDLER for not found set done=1;

	
	
	open cur;
		repeat fetch cur into conUid, conUserName, tjAmount;
		
		if not done then
			call conComSingle(conUid, parentAmount, parentLevel);
		end if;
		until done end repeat;
	close cur;

end$$

CREATE DEFINER=`b`@`localhost` PROCEDURE `conComSingle`(`conUid` INT, `parentAmount` FLOAT, `parentLevel` INT)
begin

	declare parentId int;
	declare superParentId int;
	declare conUserName varchar(255) character set utf8;
	declare p_username varchar(255) character set utf8;

	declare liqType int default 53;
	declare info varchar(255) character set utf8;

	declare done int default 0;
	declare cur cursor for
	select p.uid, p.parentId, p.username, u.username from ssc_members p, ssc_members u where u.parentId=p.uid and u.`uid`=conUid; 
	declare continue HANDLER for not found set done=1;

	open cur;
		repeat fetch cur into parentId, superParentId, p_username, conUserName;
		
		if not done then
			if parentLevel=1 then
				if parentId and parentAmount then
					set info=concat('下级[', conUserName, ']消费佣金');
					call setCoin(parentAmount, 0, parentId, liqType, 0, info, conUid, conUserName, parentLevel);
				end if;
			end if;
			
			if parentLevel=2 then
				if superParentId and parentAmount then
					set info=concat('下级[', conUserName, '<=', p_username, ']消费佣金');
					call setCoin(parentAmount, 0, superParentId, liqType, 0, info, conUid, conUserName, parentLevel);
				end if;
			end if;
		end if;
		until done end repeat;
	close cur;

end$$

CREATE DEFINER=`b`@`localhost` PROCEDURE `consumptionCommission`()
begin

	declare baseAmount float;
	declare baseAmount2 float;
	declare parentAmount float;
	declare superParentAmount float;

	call readConComSet(baseAmount, baseAmount2, parentAmount, superParentAmount);
	

	if baseAmount>0 then
		call conComAll(baseAmount, parentAmount, 1);
	end if;
	if baseAmount2>0 then
		call conComAll(baseAmount2, superParentAmount, 2);
	end if;

end$$

CREATE DEFINER=`b`@`localhost` PROCEDURE `delUser`(`_uid` INT)
begin
	
	delete from ssc_bets where `uid`=_uid;
	
	delete from ssc_coin_log where `uid`=_uid;
	

	delete from ssc_admin_log where `uid`=_uid;
	
	delete from ssc_sysadmim_session where `uid`=_uid;
	
	delete from ssc_member_cash where `uid`=_uid;
	

	delete from ssc_member_recharge where `uid`=_uid;
	
	delete from ssc_sysadmin_bank where `uid`=_uid;
	
	delete from ssc_sysmember where `uid`=_uid;
	
	delete from ssc_links where `uid`=_uid;
end$$

CREATE DEFINER=`b`@`localhost` PROCEDURE `delUser2`(`_uid` INT)
begin
	
	delete from ssc_bets where `uid`=_uid;
	
	delete from ssc_coin_log where `uid`=_uid;
	

	delete from ssc_admin_log where `uid`=_uid;
	
	delete from ssc_member_session where `uid`=_uid;
	
	delete from ssc_member_cash where `uid`=_uid;
	

	delete from ssc_member_recharge where `uid`=_uid;
	
	delete from ssc_member_bank where `uid`=_uid;
	
	delete from ssc_members where `uid`=_uid;
	
	delete from ssc_links where `uid`=_uid;
end$$

CREATE DEFINER=`b`@`localhost` PROCEDURE `delUsers`(`_coin` FLOAT(10,2), `_date` INT)
begin
	declare uid_del int;
	declare done int default 0;
	declare cur cursor for
	select distinct u.uid from ssc_members u, ssc_member_session s where u.uid=s.uid and u.coin<_coin and s.accessTime<_date and not exists(select u1.`uid` from ssc_members u1 where u1.parentId=u.`uid`)
union 
  select distinct u2.uid from ssc_members u2 where u2.coin<_coin and u2.regTime<_date and not exists (select s1.uid from ssc_member_session s1 where s1.uid=u2.uid);
	declare continue HANDLER for not found set done = 1;

	open cur;
		repeat
			fetch cur into uid_del;
			if not done then 
				call delUser(uid_del);
			end if;
		until done end repeat;
	close cur;
end$$

CREATE DEFINER=`b`@`localhost` PROCEDURE `getQzInfo`(`_uid` INT, INOUT `_fanDian` FLOAT, INOUT `_parentId` INT)
begin

	declare done int default 0;
	declare cur cursor for
	select fanDian, parentId from ssc_members where `uid`=_uid;
	declare continue HANDLER for not found set done = 1;

	open cur;
		fetch cur into _fanDian, _parentId;
	close cur;
	
	
end$$

CREATE DEFINER=`b`@`localhost` PROCEDURE `guestclear`()
begin

	declare endDate int;
	set endDate = UNIX_TIMESTAMP(now())-1*24*3600;

	
	delete from ssc_member_session where accessTime < endDate and username like 'guest_%';
	
	delete from ssc_guestbets where kjTime < endDate;
	
	delete from ssc_guestcoin_log where actionTime < endDate;
	
	delete from ssc_guestmembers where regTime < endDate;

end$$

CREATE DEFINER=`b`@`localhost` PROCEDURE `guestkanJiang`(`_betId` INT, `_zjCount` INT, `_kjData` VARCHAR(255) CHARACTER SET utf8, `_kset` VARCHAR(255) CHARACTER SET utf8)
begin
	
	declare `uid` int;									
	declare userid int;
	declare parentId int;								
	declare zparentId int;
	declare gudongId int;
	declare username varchar(32) character set utf8;	

	

	
	declare serializeId varchar(64);
	declare actionData longtext character set utf8;
	declare actionNo varchar(255);
	declare `type` int;
	declare playedId int;
	
	declare isDelete int;
	declare odds float;     
	declare _rebate float default 0;
	declare _rebatemoney float default 0;
	declare fanDian float;		
	
	declare amount float;					
	declare zjAmount float default 0;		
	declare _fanDianAmount float default 0;	

	
	declare liqType int;
	declare info varchar(255) character set utf8;
	
	declare _parentId int;		

	declare _zparentId int;		

	declare _gudongId int;		

	declare _fanDian float;		
	
	declare totalnums SMALLINT default 0;
	declare totalmoney float default 0;
	declare betinfo varchar(64) character set utf8;
	declare Groupname varchar(32) character set utf8;
	
	declare _kjTime int(11) DEFAULT 0;
	
	declare done int default 0;
	declare cur cursor for
	select b.`uid`, u.parentId, u.zparentId, u.gudongId, u.username, b.serializeId, b.actionData, b.actionNo, FROM_UNIXTIME(b.kjTime,'%Y%m%d') _kjTime, b.`type`, b.playedId, b.isDelete, b.fanDian, u.fanDian, b.odds, b.rebate, b.money, b.totalNums, b.totalMoney, b.betInfo, b.Groupname  from ssc_guestbets b, ssc_guestmembers u where b.`uid`=u.`uid` and b.id=_betId;
	declare continue handler for sqlstate '02000' set done = 1;
	
	open cur;
		repeat
			fetch cur into `uid`, parentId, zparentId, gudongId, username, serializeId, actionData, actionNo, _kjTime, `type`, playedId, isDelete, fanDian, _fanDian, odds, _rebate, amount, totalnums, totalmoney, betinfo, Groupname;
		until done end repeat;
	close cur;
	

	start transaction;
	if md5(_kset)='47df5dd3fc251a6115761119c90b964a' then
	
		

		if isDelete=0 then
		
			set userid=`uid`;
			
			set _parentId=parentId;
			set _zparentId=zparentId;
			set _gudongId=gudongId;
			
			set fanDian=_fanDian;
			
			
			if _zjCount then
				
				
				set liqType=6;
				set info='中奖奖金';
				if _zjCount = -1 then
					if totalnums>1 and totalmoney>0 and betinfo<>'' then
						set amount=totalmoney;
					end if;
					set zjAmount= amount; 

				elseif Groupname='三军' then
					set zjAmount= amount * odds + amount * (_zjCount - 1); 
				else
					set zjAmount= _zjCount * amount * odds; 
				end if;
				call guestsetCoin(zjAmount, 0, `uid`, liqType, `type`, info, _betId, serializeId, '');
				
			end if;	
	
			if _zjCount = -1 then
				set _zjCount = 0;
			end if;				
			

			if totalnums>1 and totalmoney>0 and betinfo<>'' then
				set amount=totalmoney;
			end if;

			

			if _rebate>0 and  _rebate<0.5 THEN
			set liqType=105;
			set info='退水资金';
			set _rebatemoney = amount * _rebate;
			call guestsetCoin(_rebatemoney, 0, `uid`, liqType, `type`, info, _betId, serializeId, '');
			end if;

			update ssc_guestbets set lotteryNo=_kjData, zjCount=_zjCount, bonus=zjAmount, rebateMoney=_rebatemoney where id=_betId;

			if CONVERT(DATE_FORMAT(now(),'%H%i'), SIGNED)>=100 and CONVERT(DATE_FORMAT(now(),'%H%i'), SIGNED)<105 then
			call guestclear();
			end if;
		end if;
	end if;
	
	commit;
	
end$$

CREATE DEFINER=`b`@`localhost` PROCEDURE `guestsetCoin`(`_coin` FLOAT, `_fcoin` FLOAT, `_uid` INT, `_liqType` INT, `_type` INT, `_info` VARCHAR(255) CHARACTER SET utf8, `_extfield0` INT, `_extfield1` VARCHAR(255) CHARACTER SET utf8, `_extfield2` VARCHAR(255) CHARACTER SET utf8)
begin
	
	
	DECLARE currentTime INT DEFAULT UNIX_TIMESTAMP();
	DECLARE _userCoin FLOAT;
	DECLARE _count INT  DEFAULT 0;
	
	IF _coin IS NULL THEN
		SET _coin=0;
	END IF;
	IF _fcoin IS NULL THEN
		SET _fcoin=0;
	END IF;
	

	SELECT COUNT(1) INTO _count FROM ssc_guestcoin_log WHERE  extfield0=_extfield0  AND info='中奖奖金'  AND `uid`=_uid;
	IF  _count<1 THEN
	UPDATE ssc_guestmembers SET coin = coin + _coin, fcoin = fcoin + _fcoin WHERE `uid` = _uid;
	SELECT coin INTO _userCoin FROM ssc_guestmembers WHERE `uid`=_uid;
	
	INSERT INTO ssc_guestcoin_log(coin, fcoin, userCoin, `uid`, actionTime, liqType, `type`, info, extfield0, extfield1, extfield2) VALUES(_coin, _fcoin, _userCoin, _uid, currentTime, _liqType, _type, _info, _extfield0, _extfield1, _extfield2);
	END IF;
	

end$$

CREATE DEFINER=`b`@`localhost` PROCEDURE `isFirstRechargeCom`(`_uid` INT, OUT `flag` INT)
begin
	
	declare dateTime int default unix_timestamp(curdate());
	select id into flag from ssc_member_recharge where rechargeTime>dateTime and `uid`=_uid;
	
end$$

CREATE DEFINER=`b`@`localhost` PROCEDURE `kanJiang`(`_betId` INT, `_zjCount` INT, `_kjData` VARCHAR(255) CHARACTER SET utf8, `_kset` VARCHAR(255) CHARACTER SET utf8)
begin
	
	declare `uid` int;									
	declare userid int;
	declare parentId int;								
	declare zparentId int;
	declare gudongId int;
	declare username varchar(32) character set utf8;	

	

	
	declare serializeId varchar(64);
	declare actionData longtext character set utf8;
	declare actionNo varchar(255);
	declare `type` int;
	declare playedId int;
	
	declare isDelete int;
	declare odds float;     
	declare _rebate float default 0;
	declare _rebatemoney float default 0;
	declare fanDian float;		
	
	declare amount float;					
	declare zjAmount float default 0;		
	declare _fanDianAmount float default 0;	

	
	declare liqType int;
	declare info varchar(255) character set utf8;
	
	declare _parentId int;		

	declare _zparentId int;		

	declare _gudongId int;		

	declare _fanDian float;		
	
	declare totalnums SMALLINT default 0;
	declare totalmoney float default 0;
	declare betinfo varchar(64) character set utf8;
	declare Groupname varchar(32) character set utf8;
	declare _kjTime int(11) DEFAULT 0;
	
	declare done int default 0;
	declare cur cursor for
	select b.`uid`, u.parentId, u.zparentId, u.gudongId, u.username, b.serializeId, b.actionData, b.actionNo, FROM_UNIXTIME(b.kjTime,'%Y%m%d') _kjTime, b.`type`, b.playedId, b.isDelete, b.fanDian, u.fanDian, b.odds, b.rebate, b.money, b.totalNums, b.totalMoney, b.betInfo, b.Groupname  from ssc_bets b, ssc_members u where b.`uid`=u.`uid` and b.id=_betId;
	declare continue handler for sqlstate '02000' set done = 1;
	
	open cur;
		repeat
			fetch cur into `uid`, parentId, zparentId, gudongId, username, serializeId, actionData, actionNo, _kjTime, `type`, playedId, isDelete, fanDian, _fanDian, odds, _rebate, amount, totalnums, totalmoney, betinfo, Groupname;
		until done end repeat;
	close cur;
	
	

	

	start transaction;
	if md5(_kset)='47df5dd3fc251a6115761119c90b964a' then
	
		

		if isDelete=0 then
			
			
			
		
			
			
				
				
				
				
			
			set userid=`uid`;
			
			set _parentId=parentId;
			set _zparentId=zparentId;
			set _gudongId=gudongId;
			
			set fanDian=_fanDian;
			
			
			if _zjCount then
				
				
				set liqType=6;
				set info='中奖奖金';
				if _zjCount = -1 then
					if totalnums>1 and totalmoney>0 and betinfo<>'' then
						set amount=totalmoney;
					end if;
					set zjAmount= amount; 

				elseif Groupname='三军' then
					set zjAmount= amount * odds + amount * (_zjCount - 1); 
				else
					set zjAmount= _zjCount * amount * odds; 
				end if;
				call setCoin(zjAmount, 0, `uid`, liqType, `type`, info, _betId, serializeId, '');
				
			end if;	
	
			if _zjCount = -1 then
				set _zjCount = 0;
			end if;			
			

			if totalnums>1 and totalmoney>0 and betinfo<>'' then
				set amount=totalmoney;
			end if;

				
				

				 if _parentId >0 then
				 call setDLFanDian(amount, _fanDian, _parentId,  `type`, _betId, userid, username);
				 end if;
				 if _zparentId >0 then
				 call setZDLFanDian(amount, _fanDian, _zparentId,  `type`, _betId, userid, username);
				 end if;
				 if _gudongId >0 then
				 call setGDFanDian(amount, _fanDian, _gudongId,  `type`, _betId, userid, username);
				 end if;	
				

			

			if _rebate>0 and  _rebate<0.5 THEN
			set liqType=105;
			set info='退水资金';
			set _rebatemoney = amount * _rebate;
			call setCoin(_rebatemoney, 0, `uid`, liqType, `type`, info, _betId, serializeId, '');
			end if;
			
			
			
			

			update ssc_bets set lotteryNo=_kjData, zjCount=_zjCount, bonus=zjAmount, rebateMoney=_rebatemoney where id=_betId;

			if _kjTime then				
				 call betcount(_kjTime, `type`, userid);
				 call betreport(_kjTime, userid);
			end if;

			
			
				

				
				

				
			
		end if;
	end if;
	
	commit;
	
end$$

CREATE DEFINER=`b`@`localhost` PROCEDURE `pro_count`(`_date` VARCHAR(20))
begin
	
	declare fromTime int;
	declare toTime int;
	
	if not _date then
		set _date=date_add(curdate(), interval -1 day);
	end if;
	
	set toTime=unix_timestamp(_date);
	set fromTime=toTime-24*3600;
	
	insert into ssc_count(`type`, playedId, `date`, betCount, betAmount, zjAmount)
	select `type`, playedId, _date, sum(money), sum(bonus) from ssc_bets where kjTime between fromTime and toTime and isDelete=0 group by type, playedId
	on duplicate key update betCount=values(betCount), betAmount=values(betAmount), zjAmount=values(zjAmount);


end$$

CREATE DEFINER=`b`@`localhost` PROCEDURE `pro_pay`()
begin

	declare _m_id int;					
	declare _addmoney float(10,2);		

	declare _h_fee float(10,2);		

	declare _rechargeTime varchar(20);	

	declare _rechargeId varchar(64);		

	declare _info varchar(64) character set utf8;	
	
	declare _uid int;
	declare _coin float;
	declare _fcoin float;
	
	declare _r_id int;
	declare _amount float;
	
	declare currentTime int default unix_timestamp();
	declare _liqType int default 1;
	declare info varchar(64) character set utf8 default '自动到账';
	declare done int default 0;
	
	declare isFirstRecharge int;
	
	declare cur cursor for
	select m.id, m.addmoney, m.h_fee, m.o_time, m.u_id, m.memo,		u.`uid`, u.coin, u.fcoin,		r.id, r.amount from ssc_members u, my18_pay m, ssc_member_recharge r where u.`uid`=r.`uid` and r.rechargeId=m.u_id and m.`state`=0 and r.`state`=0 and r.isDelete=0;
	declare continue HANDLER for not found set done = 1;

	start transaction;
		open cur;
			repeat
				fetch cur into _m_id, _addmoney, _h_fee, _rechargeTime, _rechargeId, _info, _uid, _coin, _fcoin, _r_id, _amount;
				
				if not done then
					
					
						call setCoin(_addmoney, 0, _uid, _liqType, 0, info, _r_id, _rechargeId, '');
						if _h_fee>0 then
							call setCoin(_h_fee, 0, _uid, _liqType, 0, '充值手续费', _r_id, _rechargeId, '');
						end if;
						update ssc_member_recharge set rechargeAmount=_addmoney+_h_fee, coin=_coin, fcoin=_fcoin, rechargeTime=currentTime, `state`=2, `info`=info where id=_r_id;
						update my18_pay set `state`=1 where id=_m_id;
						
						

						call isFirstRechargeCom(_uid, isFirstRecharge);
						if isFirstRecharge then
							call setRechargeCom(_addmoney, _uid, _r_id, _rechargeId);
						end if;
					
						
					
				end if;
				
			until done end repeat;
		close cur;
	commit;
	
	
end$$

CREATE DEFINER=`b`@`localhost` PROCEDURE `readConComSet`(OUT `baseAmount` FLOAT, OUT `baseAmount2` FLOAT, OUT `parentAmount` FLOAT, OUT `superParentAmount` FLOAT)
begin

	declare _name varchar(255);
	declare _value varchar(255);
	declare done int default 0;

	declare cur cursor for
	select name, `value` from ssc_params where name in('conCommissionBase', 'conCommissionBase2', 'conCommissionParentAmount', 'conCommissionParentAmount2');
	declare continue HANDLER for not found set done=1;

	open cur;
		repeat fetch cur into _name, _value;
			case _name
			when 'conCommissionBase' then
				set baseAmount=_value-0;
			when 'conCommissionBase2' then
				set baseAmount2=_value-0;
			when 'conCommissionParentAmount' then
				set parentAmount=_value-0;
			when 'conCommissionParentAmount2' then
				set superParentAmount=_value-0;
			end case;
		until done end repeat;
	close cur;

end$$

CREATE DEFINER=`b`@`localhost` PROCEDURE `readRechargeComSet`(OUT `baseAmount` FLOAT, OUT `parentAmount` FLOAT, OUT `superParentAmount` FLOAT)
begin

	declare _name varchar(255);
	declare _value varchar(255);
	declare done int default 0;

	declare cur cursor for
	select name, `value` from ssc_params where name in('rechargeCommissionAmount', 'rechargeCommission', 'rechargeCommission2');
	declare continue HANDLER for not found set done=1;

	open cur;
		repeat fetch cur into _name, _value;
			case _name
			when 'rechargeCommissionAmount' then
				set baseAmount=_value-0;
			when 'rechargeCommission' then
				set parentAmount=_value-0;
			when 'rechargeCommission2' then
				set superParentAmount=_value-0;
			end case;
		until done end repeat;
	close cur;

end$$

CREATE DEFINER=`b`@`localhost` PROCEDURE `setCoin`(`_coin` FLOAT, `_fcoin` FLOAT, `_uid` INT, `_liqType` INT, `_type` INT, `_info` VARCHAR(255) CHARACTER SET utf8, `_extfield0` INT, `_extfield1` VARCHAR(255) CHARACTER SET utf8, `_extfield2` VARCHAR(255) CHARACTER SET utf8)
begin
	
	
	DECLARE currentTime INT DEFAULT UNIX_TIMESTAMP();
	DECLARE _userCoin FLOAT;
	DECLARE _count INT  DEFAULT 0;
	
	IF _coin IS NULL THEN
		SET _coin=0;
	END IF;
	IF _fcoin IS NULL THEN
		SET _fcoin=0;
	END IF;
	

	SELECT COUNT(1) INTO _count FROM ssc_coin_log WHERE  extfield0=_extfield0  AND info='中奖奖金'  AND `uid`=_uid;
	IF  _count<1 THEN
	UPDATE ssc_members SET coin = coin + _coin, fcoin = fcoin + _fcoin WHERE `uid` = _uid;
	SELECT coin INTO _userCoin FROM ssc_members WHERE `uid`=_uid;
	
	INSERT INTO ssc_coin_log(coin, fcoin, userCoin, `uid`, actionTime, liqType, `type`, info, extfield0, extfield1, extfield2) VALUES(_coin, _fcoin, _userCoin, _uid, currentTime, _liqType, _type, _info, _extfield0, _extfield1, _extfield2);
	END IF;
	

end$$

CREATE DEFINER=`b`@`localhost` PROCEDURE `setDLFanDian`(`amount` FLOAT, INOUT `_fanDian` FLOAT, INOUT `_parentId` INT, `_type` INT, `srcBetId` INT, `srcUid` INT, INOUT `srcUserName` VARCHAR(255))
begin
	
	declare p_parentId int;		

	declare p_fanDian float;	
	declare p_username varchar(64);
	
	
	declare liqType int default 2;
	declare info varchar(255) character set utf8;
	
	declare done int default 0;
	declare cur cursor for
	select fanDian, uid, username from ssc_members where `uid`=_parentId;
	declare continue HANDLER for not found set done = 1;

	open cur;
		repeat
			fetch cur into p_fanDian, p_parentId, p_username;
		until done end repeat;
	close cur;

	if p_fanDian > _fanDian then
		set info=concat('下家[', cast(srcUserName as char), ']投注返点');
		call setCoin(amount * (p_fanDian - _fanDian) / 100, 0, _parentId, liqType, _type, info, srcBetId, srcUid, srcUserName);
	end if;
	
	set _parentId=p_parentId;
	set _fanDian=p_fanDian;
	set srcUserName=concat(p_username, '<=', srcUserName);
	
end$$

CREATE DEFINER=`b`@`localhost` PROCEDURE `setGDFanDian`(`amount` FLOAT, INOUT `_fanDian` FLOAT, INOUT `_gudongId` INT, `_type` INT, `srcBetId` INT, `srcUid` INT, INOUT `srcUserName` VARCHAR(255))
begin
	
	declare p_gudongId int;		

	declare p_fanDian float;	
	declare p_username varchar(64);
	
	declare liqType int default 3;
	
	declare info varchar(255) character set utf8;
	
	declare done int default 0;
	declare cur cursor for
	select fanDian, uid, username from ssc_members where `uid`=_gudongId;
	declare continue HANDLER for not found set done = 1;

	open cur;
		repeat
			fetch cur into p_fanDian, p_gudongId, p_username;
		until done end repeat;
	close cur;

	if p_fanDian > _fanDian then
		set info=concat('下家[', cast(srcUserName as char), ']投注返点');
		call setCoin(amount * (p_fanDian - _fanDian) / 100, 0, _gudongId, liqType, _type, info, srcBetId, srcUid, srcUserName);
	end if;
	
	set _gudongId=p_gudongId;
	set _fanDian=p_fanDian;
	set srcUserName=concat(p_username, '<=', srcUserName);
	
end$$

CREATE DEFINER=`b`@`localhost` PROCEDURE `setRechargeCom`(`_coin` FLOAT, `_uid` INT, `_rechargeId` INT, `_serId` INT)
begin
	
	declare baseAmount float;
	declare parentAmount float;
	declare superParentAmount float;
	
	declare _parentId int;
	declare _surperParentId int;
	
	declare liqType int default 52;
	declare info varchar(255) character set utf8 default '充值佣金';
	
	declare done int default 0;
	declare cur cursor for
	select p.`uid`, p.parentId from ssc_members p, ssc_members u where p.`uid`=u.parentId and u.`uid`=_uid;
	declare continue HANDLER for not found set done=1;
	
	call readRechargeComSet(baseAmount, parentAmount, superParentAmount);
	
	open cur;
		repeat fetch cur into _parentId, _surperParentId;
			if not done then
				if _parentId then
					call setCoin(parentAmount, 0, _parentId, liqType, 0, info, _rechargeId, _serId, '');
				end if;
				
				if _surperParentId then
					call setCoin(superParentAmount, 0, _surperParentId, liqType, 0, info, _rechargeId, _serId, '');
				end if;
			end if;
		until done end repeat;
	close cur;
	
end$$

CREATE DEFINER=`b`@`localhost` PROCEDURE `setZDLFanDian`(`amount` FLOAT, INOUT `_fanDian` FLOAT, INOUT `_zparentId` INT, `_type` INT, `srcBetId` INT, `srcUid` INT, INOUT `srcUserName` VARCHAR(255))
begin
	
	declare p_zparentId int;		

	declare p_fanDian float;	
	declare p_username varchar(64);
	
	declare liqType int default 3;
	
	declare info varchar(255) character set utf8;
	
	declare done int default 0;
	declare cur cursor for
	select fanDian, uid, username from ssc_members where `uid`=_zparentId;
	declare continue HANDLER for not found set done = 1;

	open cur;
		repeat
			fetch cur into p_fanDian, p_zparentId, p_username;
		until done end repeat;
	close cur;

	if p_fanDian > _fanDian then
		set info=concat('下家[', cast(srcUserName as char), ']投注返点');
		call setCoin(amount * (p_fanDian - _fanDian) / 100, 0, _zparentId, liqType, _type, info, srcBetId, srcUid, srcUserName);
	end if;
	
	set _zparentId=p_zparentId;
	set _fanDian=p_fanDian;
	set srcUserName=concat(p_username, '<=', srcUserName);
	
end$$

CREATE DEFINER=`b`@`localhost` PROCEDURE `summarizeData`(`_type` INT, `_issue` VARCHAR(32))
begin

  declare _billCount int(5) DEFAULT 0;
  declare _pjed int(5) DEFAULT 0;
  declare _zjCount int(5) DEFAULT 0;
  declare _userCount int(5) DEFAULT 0;

  declare _betAmount double(18,4) DEFAULT 0.0000;
  declare _zjAmount double(18,4) DEFAULT 0.0000;
  declare _fanDianAmount double(18,4) DEFAULT 0.0000;
	
	select count(*) into _billCount from ssc_bets where isDelete=0 and type=_type and actionNo=_issue;
	select count(*) into _pjed from ssc_bets where isDelete=0 and type=_type and actionNo=_issue and lotteryNo!='';
	select count(*) into _zjCount from ssc_bets where isDelete=0 and type=_type and actionNo=_issue and zjCount>0;
	select count(b.uid) into _userCount from (select uid from ssc_bets where isDelete=0 and type=_type and actionNo=_issue group by uid) b;

	select sum(amount) into _betAmount from ssc_bets where isDelete=0 and type=_type and actionNo=_issue;
	select sum(bonus) into _zjAmount from ssc_bets where isDelete=0 and type=_type and actionNo=_issue;
	select sum(fanDianAmount) into _fanDianAmount from ssc_bets where isDelete=0 and type=_type and actionNo=_issue;

	update ssc_data set billCount=_billCount, pjed=_pjed, zjCount=_zjCount, userCount=_userCount, betAmount=_betAmount, zjAmount=_zjAmount, fanDianAmount=_fanDianAmount where type=_type and number=_issue;
end$$

CREATE DEFINER=`b`@`localhost` PROCEDURE `summarizePlatform`(`_date` INT(8))
begin

  declare _billCount int(5) DEFAULT 0;
  declare _pjed int(5) DEFAULT 0;
  declare _zjCount int(5) DEFAULT 0;
  declare _userCount int(5) DEFAULT 0;

  declare _betAmount double(18,4) DEFAULT 0.0000;
  declare _zjAmount double(18,4) DEFAULT 0.0000;
  declare _fanDianAmount double(18,4) DEFAULT 0.0000;
	
	select count(*) into _billCount from ssc_bets where isDelete=0 and type=_type and actionNo=_issue;
	select count(*) into _pjed from ssc_bets where isDelete=0 and type=_type and actionNo=_issue and lotteryNo!='';
	select count(*) into _zjCount from ssc_bets where isDelete=0 and type=_type and actionNo=_issue and zjCount>0;
	select count(b.uid) into _userCount from (select uid from ssc_bets where isDelete=0 and type=_type and actionNo=_issue group by uid) b;

	select sum(amount) into _betAmount from ssc_bets where isDelete=0 and type=_type and actionNo=_issue;
	select sum(bonus) into _zjAmount from ssc_bets where isDelete=0 and type=_type and actionNo=_issue;
	select sum(fanDianAmount) into _fanDianAmount from ssc_bets where isDelete=0 and type=_type and actionNo=_issue;

	update ssc_data set billCount=_billCount, pjed=_pjed, zjCount=_zjCount, userCount=_userCount, betAmount=_betAmount, zjAmount=_zjAmount, fanDianAmount=_fanDianAmount where type=_type and number=_issue;
end$$

CREATE DEFINER=`b`@`localhost` PROCEDURE `summarizePlayed`(`_date` INT(8), `_type` TINYINT(3), `_played` INT(11), `_issue` VARCHAR(32))
begin

  declare _pri int(11) DEFAULT 0;
  
	declare _betCount int(5) DEFAULT 0;
  declare _betAmount double(15,4) DEFAULT 0.0000;
  declare _zjAmount double(15,4) DEFAULT 0.0000;
  declare _fanDianAmount double(15,4) DEFAULT 0.0000;
	
	select id into _pri from ssc_played_daily_count where date=_date and type=_type and played=_played;
	
	if _pri=0 or _pri is null THEN
		insert into ssc_played_daily_count (date, type, played) values(_date, _type, _played);
		select id into _pri from ssc_played_daily_count where date=_date and type=_type and played=_played;
	end if;




	select count(*) into _betCount from ssc_bets where isDelete=0 and type=_type and playedId=_played and lotteryNo!='';
	

	select sum(money) into _betAmount from ssc_bets where isDelete=0 and type=_type and playedId=_played and lotteryNo!='';

	select sum(bonus) into _zjAmount from ssc_bets where isDelete=0 and type=_type and playedId=_played and lotteryNo!='';

	select sum(fanDianAmount) into _fanDianAmount from ssc_bets where isDelete=0 and type=_type and playedId=_played and lotteryNo!='';
	
	



	if _betCount is null THEN
		set _betCount = 0;
	end if;

	if _betAmount is null THEN
		set _betAmount = 0;
	end if;
	if _zjAmount is null THEN
		set _zjAmount = 0;
	end if;
	if _fanDianAmount is null THEN
		set _fanDianAmount = 0;
	end if;



	update ssc_played_daily_count set betCount=_betCount, betAmount=_betAmount, zjAmount=_zjAmount, fanDianAmount=_fanDianAmount where id=_pri;
end$$

CREATE DEFINER=`b`@`localhost` PROCEDURE `userallreport_copy`(`_date` INT(8), `_type` TINYINT(3), `_uid` INT(10))
begin

  declare _pri int(11) DEFAULT 0;
  
	declare _betCount int(5) DEFAULT 0;
  declare _betAmount double(15,4) DEFAULT 0.0000;
  declare _zjAmount double(15,4) DEFAULT 0.0000;
  declare _fanDianAmount double(15,4) DEFAULT 0.0000;
	
	select id into _pri from ssc_count where date=_date and type=_type;
	
	if _pri=0 or _pri is null THEN
		insert into ssc_count (date, type) values(_date, _type);
		select id into _pri from ssc_count where date=_date and type=_type;
	end if;




	select count(*) into _betCount from ssc_bets where isDelete=0 and type=_type and lotteryNo!='';
	

	select sum(money) into _betAmount from ssc_bets where isDelete=0 and type=_type and lotteryNo!='';

	select sum(bonus) into _zjAmount from ssc_bets where isDelete=0 and type=_type and lotteryNo!='';

	select sum(fanDianAmount) into _fanDianAmount from ssc_bets where isDelete=0 and type=_type and lotteryNo!='';
	
	



	if _betCount is null THEN
		set _betCount = 0;
	end if;

	if _betAmount is null THEN
		set _betAmount = 0;
	end if;
	if _zjAmount is null THEN
		set _zjAmount = 0;
	end if;
	if _fanDianAmount is null THEN
		set _fanDianAmount = 0;
	end if;



	update ssc_count set betCount=_betCount, betAmount=_betAmount, zjAmount=_zjAmount where id=_pri;
end$$

CREATE DEFINER=`b`@`localhost` PROCEDURE `userallreport_copy1`(`_date` INT(8), `_type` TINYINT(3), `_uid` INT(10))
begin

	declare _pri int(11) DEFAULT 0; 
	declare _betCount int(5) DEFAULT 0;
	declare _betAmount double(15,4) DEFAULT 0.0000;
	declare _zjAmount double(15,4) DEFAULT 0.0000;
	declare _rebateMoney double(15,4) DEFAULT 0.0000;
	declare _username VARCHAR(16) DEFAULT null;
	declare _gudongId int(10) DEFAULT 0; 
	declare _zparentId int(10) DEFAULT 0; 
	declare _parentId int(10) DEFAULT 0; 

	if _uid then

	select id into _pri from ssc_count where date=_date and uid=__uid and type=_type;
	
	if _pri=0 or _pri is null THEN
		insert into ssc_count (date, uid) values(_date, _uid);
		select id into _pri from ssc_count where date=_date and uid=_uid and type=_type;
	end if;




	select count(*) into _betCount from ssc_bets where isDelete=0 and uid=_uid and lotteryNo!='' and type=_type;
	

	select sum(money) into _betAmount from ssc_bets where isDelete=0 and uid=_uid and lotteryNo!='' and type=_type;

	select sum(bonus) into _zjAmount from ssc_bets where isDelete=0 and uid=_uid and lotteryNo!='' and type=_type;

	select sum(rebateMoney) into _rebateMoney from ssc_bets where isDelete=0 and uid=_uid and lotteryNo!='' and type=_type;
	
	select uid into _uid from ssc_members where isDelete=0 and uid=_uid;
	select username into _username from ssc_members where isDelete=0 and uid=_uid;
	select gudongId into _gudongId from ssc_members where isDelete=0 and uid=_uid;
	select zparentId into _zparentId from ssc_members where isDelete=0 and uid=_uid;	
	select parentId into _parentId from ssc_members where isDelete=0 and uid=_uid;



	if _betCount is null THEN
		set _betCount = 0;
	end if;

	if _betAmount is null THEN
		set _betAmount = 0;
	end if;
	if _zjAmount is null THEN
		set _zjAmount = 0;
	end if;
	if _rebateMoney is null THEN
		set _rebateMoney = 0;
	end if;



	update ssc_count set betCount=_betCount, betAmount=_betAmount, zjAmount=_zjAmount, rebateMoney=_rebateMoney, username=_username, uid=_uid, gudongId=_gudongId, zparentId=_zparentId, parentId=_parentId where id=_pri;
	end if;

end$$

DELIMITER ;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_account`
--

CREATE TABLE IF NOT EXISTS `wqwdb_account` (
  `acid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `uniacid` int(10) unsigned NOT NULL,
  `hash` varchar(8) NOT NULL,
  `type` tinyint(3) unsigned NOT NULL,
  `isconnect` tinyint(4) NOT NULL,
  `isdeleted` tinyint(3) unsigned NOT NULL,
  `endtime` int(10) unsigned NOT NULL,
  PRIMARY KEY (`acid`),
  KEY `idx_uniacid` (`uniacid`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=2 ;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_account_aliapp`
--

CREATE TABLE IF NOT EXISTS `wqwdb_account_aliapp` (
  `acid` int(10) NOT NULL,
  `uniacid` int(10) NOT NULL,
  `level` tinyint(4) unsigned NOT NULL,
  `name` varchar(30) NOT NULL,
  `description` varchar(255) NOT NULL,
  `key` varchar(16) NOT NULL,
  PRIMARY KEY (`acid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_account_phoneapp`
--

CREATE TABLE IF NOT EXISTS `wqwdb_account_phoneapp` (
  `acid` int(11) NOT NULL,
  `uniacid` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`acid`),
  KEY `uniacid` (`uniacid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_account_webapp`
--

CREATE TABLE IF NOT EXISTS `wqwdb_account_webapp` (
  `acid` int(11) NOT NULL,
  `uniacid` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`acid`),
  KEY `uniacid` (`uniacid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_account_wechats`
--

CREATE TABLE IF NOT EXISTS `wqwdb_account_wechats` (
  `acid` int(10) unsigned NOT NULL,
  `uniacid` int(10) unsigned NOT NULL,
  `token` varchar(32) NOT NULL,
  `encodingaeskey` varchar(255) NOT NULL,
  `level` tinyint(4) unsigned NOT NULL,
  `name` varchar(30) NOT NULL,
  `account` varchar(30) NOT NULL,
  `original` varchar(50) NOT NULL,
  `signature` varchar(100) NOT NULL,
  `country` varchar(10) NOT NULL,
  `province` varchar(3) NOT NULL,
  `city` varchar(15) NOT NULL,
  `username` varchar(30) NOT NULL,
  `password` varchar(32) NOT NULL,
  `lastupdate` int(10) unsigned NOT NULL,
  `key` varchar(50) NOT NULL,
  `secret` varchar(50) NOT NULL,
  `styleid` int(10) unsigned NOT NULL,
  `subscribeurl` varchar(120) NOT NULL,
  `auth_refresh_token` varchar(255) NOT NULL,
  PRIMARY KEY (`acid`),
  KEY `idx_key` (`key`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_account_wxapp`
--

CREATE TABLE IF NOT EXISTS `wqwdb_account_wxapp` (
  `acid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `uniacid` int(10) NOT NULL,
  `token` varchar(32) NOT NULL,
  `encodingaeskey` varchar(43) NOT NULL,
  `level` tinyint(4) NOT NULL,
  `account` varchar(30) NOT NULL,
  `original` varchar(50) NOT NULL,
  `key` varchar(50) NOT NULL,
  `secret` varchar(50) NOT NULL,
  `name` varchar(30) NOT NULL,
  `appdomain` varchar(255) NOT NULL,
  PRIMARY KEY (`acid`),
  KEY `uniacid` (`uniacid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_account_xzapp`
--

CREATE TABLE IF NOT EXISTS `wqwdb_account_xzapp` (
  `acid` int(11) NOT NULL,
  `uniacid` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `original` varchar(50) NOT NULL,
  `lastupdate` int(10) NOT NULL,
  `styleid` int(10) NOT NULL,
  `createtime` int(10) NOT NULL,
  `token` varchar(32) NOT NULL,
  `encodingaeskey` varchar(255) NOT NULL,
  `xzapp_id` varchar(30) NOT NULL,
  `level` tinyint(4) unsigned NOT NULL,
  `key` varchar(80) NOT NULL,
  `secret` varchar(80) NOT NULL,
  PRIMARY KEY (`acid`),
  KEY `uniacid` (`uniacid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_article_category`
--

CREATE TABLE IF NOT EXISTS `wqwdb_article_category` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(30) NOT NULL,
  `displayorder` tinyint(3) unsigned NOT NULL,
  `type` varchar(15) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `type` (`type`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_article_comment`
--

CREATE TABLE IF NOT EXISTS `wqwdb_article_comment` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `articleid` int(10) NOT NULL,
  `parentid` int(10) NOT NULL,
  `uid` int(10) NOT NULL,
  `content` varchar(500) DEFAULT NULL,
  `is_like` tinyint(1) NOT NULL,
  `is_reply` tinyint(1) NOT NULL,
  `like_num` int(10) NOT NULL,
  `createtime` int(10) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `articleid` (`articleid`) USING BTREE
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_article_news`
--

CREATE TABLE IF NOT EXISTS `wqwdb_article_news` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `cateid` int(10) unsigned NOT NULL,
  `title` varchar(100) NOT NULL,
  `content` mediumtext NOT NULL,
  `thumb` varchar(255) NOT NULL,
  `source` varchar(255) NOT NULL,
  `author` varchar(50) NOT NULL,
  `displayorder` tinyint(3) unsigned NOT NULL,
  `is_display` tinyint(3) unsigned NOT NULL,
  `is_show_home` tinyint(3) unsigned NOT NULL,
  `createtime` int(10) unsigned NOT NULL,
  `click` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `title` (`title`),
  KEY `cateid` (`cateid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_article_notice`
--

CREATE TABLE IF NOT EXISTS `wqwdb_article_notice` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `cateid` int(10) unsigned NOT NULL,
  `title` varchar(100) NOT NULL,
  `content` mediumtext NOT NULL,
  `displayorder` tinyint(3) unsigned NOT NULL,
  `is_display` tinyint(3) unsigned NOT NULL,
  `is_show_home` tinyint(3) unsigned NOT NULL,
  `createtime` int(10) unsigned NOT NULL,
  `click` int(10) unsigned NOT NULL,
  `style` varchar(200) NOT NULL,
  `group` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `title` (`title`),
  KEY `cateid` (`cateid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_article_unread_notice`
--

CREATE TABLE IF NOT EXISTS `wqwdb_article_unread_notice` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `notice_id` int(10) unsigned NOT NULL,
  `uid` int(10) unsigned NOT NULL,
  `is_new` tinyint(3) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `uid` (`uid`),
  KEY `notice_id` (`notice_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_attachment_group`
--

CREATE TABLE IF NOT EXISTS `wqwdb_attachment_group` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(25) NOT NULL,
  `uniacid` int(11) DEFAULT NULL,
  `uid` int(11) DEFAULT NULL,
  `type` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_basic_reply`
--

CREATE TABLE IF NOT EXISTS `wqwdb_basic_reply` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `rid` int(10) unsigned NOT NULL,
  `content` varchar(1000) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `rid` (`rid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_business`
--

CREATE TABLE IF NOT EXISTS `wqwdb_business` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `weid` int(10) unsigned NOT NULL,
  `title` varchar(50) NOT NULL,
  `thumb` varchar(255) NOT NULL,
  `content` varchar(1000) NOT NULL,
  `phone` varchar(15) NOT NULL,
  `qq` varchar(15) NOT NULL,
  `province` varchar(50) NOT NULL,
  `city` varchar(50) NOT NULL,
  `dist` varchar(50) NOT NULL,
  `address` varchar(500) NOT NULL,
  `lng` varchar(10) NOT NULL,
  `lat` varchar(10) NOT NULL,
  `industry1` varchar(10) NOT NULL,
  `industry2` varchar(10) NOT NULL,
  `createtime` int(10) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_lat_lng` (`lng`,`lat`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_core_attachment`
--

CREATE TABLE IF NOT EXISTS `wqwdb_core_attachment` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `uniacid` int(10) unsigned NOT NULL,
  `uid` int(10) unsigned NOT NULL,
  `filename` varchar(255) NOT NULL,
  `attachment` varchar(255) NOT NULL,
  `type` tinyint(3) unsigned NOT NULL,
  `createtime` int(10) unsigned NOT NULL,
  `module_upload_dir` varchar(100) NOT NULL,
  `group_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=2 ;

--
-- 转存表中的数据 `wqwdb_core_attachment`
--

INSERT INTO `wqwdb_core_attachment` (`id`, `uniacid`, `uid`, `filename`, `attachment`, `type`, `createtime`, `module_upload_dir`, `group_id`) VALUES
(1, 0, 1, '5d5675a0c159d.jpg', 'images/global/rIUBUNKni4DKBKcS88cS1D4i3KIIkG.jpg', 1, 1566287689, '', -1);

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_core_cache`
--

CREATE TABLE IF NOT EXISTS `wqwdb_core_cache` (
  `key` varchar(100) NOT NULL,
  `value` longtext NOT NULL,
  PRIMARY KEY (`key`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- 转存表中的数据 `wqwdb_core_cache`
--

INSERT INTO `wqwdb_core_cache` (`key`, `value`) VALUES
('we7:account_ticket', 's:0:"";'),
('we7:userbasefields', 'a:46:{s:7:"uniacid";s:17:"同一公众号id";s:7:"groupid";s:8:"分组id";s:7:"credit1";s:6:"积分";s:7:"credit2";s:6:"余额";s:7:"credit3";s:19:"预留积分类型3";s:7:"credit4";s:19:"预留积分类型4";s:7:"credit5";s:19:"预留积分类型5";s:7:"credit6";s:19:"预留积分类型6";s:10:"createtime";s:12:"加入时间";s:6:"mobile";s:12:"手机号码";s:5:"email";s:12:"电子邮箱";s:8:"realname";s:12:"真实姓名";s:8:"nickname";s:6:"昵称";s:6:"avatar";s:6:"头像";s:2:"qq";s:5:"QQ号";s:6:"gender";s:6:"性别";s:5:"birth";s:6:"生日";s:13:"constellation";s:6:"星座";s:6:"zodiac";s:6:"生肖";s:9:"telephone";s:12:"固定电话";s:6:"idcard";s:12:"证件号码";s:9:"studentid";s:6:"学号";s:5:"grade";s:6:"班级";s:7:"address";s:6:"地址";s:7:"zipcode";s:6:"邮编";s:11:"nationality";s:6:"国籍";s:6:"reside";s:9:"居住地";s:14:"graduateschool";s:12:"毕业学校";s:7:"company";s:6:"公司";s:9:"education";s:6:"学历";s:10:"occupation";s:6:"职业";s:8:"position";s:6:"职位";s:7:"revenue";s:9:"年收入";s:15:"affectivestatus";s:12:"情感状态";s:10:"lookingfor";s:13:" 交友目的";s:9:"bloodtype";s:6:"血型";s:6:"height";s:6:"身高";s:6:"weight";s:6:"体重";s:6:"alipay";s:15:"支付宝帐号";s:3:"msn";s:3:"MSN";s:6:"taobao";s:12:"阿里旺旺";s:4:"site";s:6:"主页";s:3:"bio";s:12:"自我介绍";s:8:"interest";s:12:"兴趣爱好";s:8:"password";s:6:"密码";s:12:"pay_password";s:12:"支付密码";}'),
('we7:usersfields', 'a:47:{s:8:"realname";s:12:"真实姓名";s:8:"nickname";s:6:"昵称";s:6:"avatar";s:6:"头像";s:2:"qq";s:5:"QQ号";s:6:"mobile";s:12:"手机号码";s:3:"vip";s:9:"VIP级别";s:6:"gender";s:6:"性别";s:9:"birthyear";s:12:"出生生日";s:13:"constellation";s:6:"星座";s:6:"zodiac";s:6:"生肖";s:9:"telephone";s:12:"固定电话";s:6:"idcard";s:12:"证件号码";s:9:"studentid";s:6:"学号";s:5:"grade";s:6:"班级";s:7:"address";s:12:"邮寄地址";s:7:"zipcode";s:6:"邮编";s:11:"nationality";s:6:"国籍";s:14:"resideprovince";s:12:"居住地址";s:14:"graduateschool";s:12:"毕业学校";s:7:"company";s:6:"公司";s:9:"education";s:6:"学历";s:10:"occupation";s:6:"职业";s:8:"position";s:6:"职位";s:7:"revenue";s:9:"年收入";s:15:"affectivestatus";s:12:"情感状态";s:10:"lookingfor";s:13:" 交友目的";s:9:"bloodtype";s:6:"血型";s:6:"height";s:6:"身高";s:6:"weight";s:6:"体重";s:6:"alipay";s:15:"支付宝帐号";s:3:"msn";s:3:"MSN";s:5:"email";s:12:"电子邮箱";s:6:"taobao";s:12:"阿里旺旺";s:4:"site";s:6:"主页";s:3:"bio";s:12:"自我介绍";s:8:"interest";s:12:"兴趣爱好";s:7:"uniacid";s:17:"同一公众号id";s:7:"groupid";s:8:"分组id";s:7:"credit1";s:6:"积分";s:7:"credit2";s:6:"余额";s:7:"credit3";s:19:"预留积分类型3";s:7:"credit4";s:19:"预留积分类型4";s:7:"credit5";s:19:"预留积分类型5";s:7:"credit6";s:19:"预留积分类型6";s:10:"createtime";s:12:"加入时间";s:8:"password";s:12:"用户密码";s:12:"pay_password";s:12:"支付密码";}'),
('we7:setting', 'a:6:{s:9:"copyright";a:37:{s:6:"status";i:0;s:10:"verifycode";N;s:6:"reason";s:0:"";s:8:"sitename";s:0:"";s:3:"url";s:7:"http://";s:8:"statcode";s:0:"";s:10:"footerleft";s:0:"";s:11:"footerright";s:0:"";s:4:"icon";s:0:"";s:5:"flogo";s:0:"";s:14:"background_img";s:48:"images/global/rIUBUNKni4DKBKcS88cS1D4i3KIIkG.jpg";s:6:"slides";s:2:"N;";s:6:"notice";s:0:"";s:5:"blogo";s:0:"";s:8:"baidumap";a:2:{s:3:"lng";s:0:"";s:3:"lat";s:0:"";}s:7:"company";s:0:"";s:14:"companyprofile";s:0:"";s:7:"address";s:0:"";s:6:"person";s:0:"";s:5:"phone";s:0:"";s:2:"qq";s:0:"";s:5:"email";s:0:"";s:8:"keywords";s:0:"";s:11:"description";s:0:"";s:12:"showhomepage";i:0;s:13:"leftmenufixed";i:0;s:13:"mobile_status";N;s:10:"login_type";N;s:10:"log_status";i:0;s:14:"develop_status";i:0;s:3:"icp";s:0:"";s:8:"sms_name";s:0:"";s:12:"sms_password";s:0:"";s:8:"sms_sign";s:0:"";s:4:"bind";N;s:12:"welcome_link";N;s:10:"oauth_bind";N;}s:8:"authmode";i:1;s:5:"close";a:2:{s:6:"status";s:1:"0";s:6:"reason";s:0:"";}s:8:"register";a:4:{s:4:"open";i:1;s:6:"verify";i:0;s:4:"code";i:1;s:7:"groupid";i:1;}s:7:"cloudip";a:2:{s:2:"ip";s:15:"132.232.105.191";s:6:"expire";i:1566291426;}s:5:"basic";a:1:{s:8:"template";s:5:"black";}}'),
('we7:module_receive_enable', 'a:0:{}'),
('setting', 'a:6:{s:9:"copyright";a:37:{s:6:"status";i:0;s:10:"verifycode";N;s:6:"reason";s:0:"";s:8:"sitename";s:0:"";s:3:"url";s:7:"http://";s:8:"statcode";s:0:"";s:10:"footerleft";s:0:"";s:11:"footerright";s:0:"";s:4:"icon";s:0:"";s:5:"flogo";s:0:"";s:14:"background_img";s:48:"images/global/rIUBUNKni4DKBKcS88cS1D4i3KIIkG.jpg";s:6:"slides";s:2:"N;";s:6:"notice";s:0:"";s:5:"blogo";s:0:"";s:8:"baidumap";a:2:{s:3:"lng";s:0:"";s:3:"lat";s:0:"";}s:7:"company";s:0:"";s:14:"companyprofile";s:0:"";s:7:"address";s:0:"";s:6:"person";s:0:"";s:5:"phone";s:0:"";s:2:"qq";s:0:"";s:5:"email";s:0:"";s:8:"keywords";s:0:"";s:11:"description";s:0:"";s:12:"showhomepage";i:0;s:13:"leftmenufixed";i:0;s:13:"mobile_status";N;s:10:"login_type";N;s:10:"log_status";i:0;s:14:"develop_status";i:0;s:3:"icp";s:0:"";s:8:"sms_name";s:0:"";s:12:"sms_password";s:0:"";s:8:"sms_sign";s:0:"";s:4:"bind";N;s:12:"welcome_link";N;s:10:"oauth_bind";N;}s:8:"authmode";i:1;s:5:"close";a:2:{s:6:"status";s:1:"0";s:6:"reason";s:0:"";}s:8:"register";a:4:{s:4:"open";i:1;s:6:"verify";i:0;s:4:"code";i:1;s:7:"groupid";i:1;}s:7:"cloudip";a:2:{s:2:"ip";s:15:"132.232.105.191";s:6:"expire";i:1566291426;}s:5:"basic";a:1:{s:8:"template";s:5:"black";}}'),
('we7:system_frame:0', 'a:12:{s:4:"help";a:8:{s:5:"title";s:12:"系统帮助";s:4:"icon";s:12:"wi wi-market";s:3:"url";s:29:"./index.php?c=help&a=display&";s:7:"section";a:0:{}s:5:"blank";b:0;s:9:"is_system";b:1;s:10:"is_display";b:0;s:12:"displayorder";i:0;}s:8:"platform";a:7:{s:5:"title";s:6:"平台";s:4:"icon";s:14:"wi wi-platform";s:3:"url";s:44:"./index.php?c=account&a=display&do=platform&";s:7:"section";a:0:{}s:9:"is_system";b:1;s:10:"is_display";b:1;s:12:"displayorder";i:2;}s:7:"account";a:7:{s:5:"title";s:9:"公众号";s:4:"icon";s:18:"wi wi-white-collar";s:3:"url";s:41:"./index.php?c=home&a=welcome&do=platform&";s:7:"section";a:5:{s:13:"platform_plus";a:3:{s:5:"title";s:12:"增强功能";s:4:"menu";a:5:{s:14:"platform_reply";a:9:{s:9:"is_system";i:1;s:10:"is_display";i:0;s:5:"title";s:12:"自动回复";s:3:"url";s:31:"./index.php?c=platform&a=reply&";s:15:"permission_name";s:14:"platform_reply";s:4:"icon";s:11:"wi wi-reply";s:12:"displayorder";i:5;s:2:"id";N;s:14:"sub_permission";a:0:{}}s:13:"platform_menu";a:9:{s:9:"is_system";i:1;s:10:"is_display";i:0;s:5:"title";s:15:"自定义菜单";s:3:"url";s:38:"./index.php?c=platform&a=menu&do=post&";s:15:"permission_name";s:13:"platform_menu";s:4:"icon";s:16:"wi wi-custommenu";s:12:"displayorder";i:4;s:2:"id";N;s:14:"sub_permission";N;}s:11:"platform_qr";a:9:{s:9:"is_system";i:1;s:10:"is_display";i:0;s:5:"title";s:22:"二维码/转化链接";s:3:"url";s:28:"./index.php?c=platform&a=qr&";s:15:"permission_name";s:11:"platform_qr";s:4:"icon";s:12:"wi wi-qrcode";s:12:"displayorder";i:3;s:2:"id";N;s:14:"sub_permission";a:0:{}}s:17:"platform_material";a:9:{s:9:"is_system";i:1;s:10:"is_display";i:0;s:5:"title";s:16:"素材/编辑器";s:3:"url";s:34:"./index.php?c=platform&a=material&";s:15:"permission_name";s:17:"platform_material";s:4:"icon";s:12:"wi wi-redact";s:12:"displayorder";i:2;s:2:"id";N;s:14:"sub_permission";a:2:{i:0;a:3:{s:5:"title";s:13:"添加/编辑";s:3:"url";s:39:"./index.php?c=platform&a=material-post&";s:15:"permission_name";s:13:"material_post";}i:1;a:2:{s:5:"title";s:6:"删除";s:15:"permission_name";s:24:"platform_material_delete";}}}s:13:"platform_site";a:9:{s:9:"is_system";i:1;s:10:"is_display";i:0;s:5:"title";s:16:"微官网-文章";s:3:"url";s:38:"./index.php?c=site&a=multi&do=display&";s:15:"permission_name";s:13:"platform_site";s:4:"icon";s:10:"wi wi-home";s:12:"displayorder";i:1;s:2:"id";N;s:14:"sub_permission";a:0:{}}}s:10:"is_display";i:0;}s:15:"platform_module";a:3:{s:5:"title";s:12:"应用模块";s:4:"menu";a:0:{}s:10:"is_display";b:1;}s:2:"mc";a:3:{s:5:"title";s:6:"粉丝";s:4:"menu";a:2:{s:7:"mc_fans";a:9:{s:9:"is_system";i:1;s:10:"is_display";i:0;s:5:"title";s:12:"粉丝管理";s:3:"url";s:24:"./index.php?c=mc&a=fans&";s:15:"permission_name";s:7:"mc_fans";s:4:"icon";s:16:"wi wi-fansmanage";s:12:"displayorder";i:2;s:2:"id";N;s:14:"sub_permission";N;}s:9:"mc_member";a:9:{s:9:"is_system";i:1;s:10:"is_display";i:0;s:5:"title";s:12:"会员管理";s:3:"url";s:26:"./index.php?c=mc&a=member&";s:15:"permission_name";s:9:"mc_member";s:4:"icon";s:10:"wi wi-fans";s:12:"displayorder";i:1;s:2:"id";N;s:14:"sub_permission";N;}}s:10:"is_display";i:0;}s:7:"profile";a:3:{s:5:"title";s:6:"配置";s:4:"menu";a:4:{s:7:"profile";a:9:{s:9:"is_system";i:1;s:10:"is_display";i:0;s:5:"title";s:12:"参数配置";s:3:"url";s:31:"./index.php?c=profile&a=remote&";s:15:"permission_name";s:15:"profile_setting";s:4:"icon";s:23:"wi wi-parameter-setting";s:12:"displayorder";i:4;s:2:"id";N;s:14:"sub_permission";N;}s:7:"payment";a:9:{s:9:"is_system";i:1;s:10:"is_display";i:0;s:5:"title";s:12:"支付参数";s:3:"url";s:32:"./index.php?c=profile&a=payment&";s:15:"permission_name";s:19:"profile_pay_setting";s:4:"icon";s:17:"wi wi-pay-setting";s:12:"displayorder";i:3;s:2:"id";N;s:14:"sub_permission";N;}s:15:"app_module_link";a:9:{s:9:"is_system";i:1;s:10:"is_display";i:0;s:5:"title";s:12:"数据同步";s:3:"url";s:44:"./index.php?c=profile&a=module-link-uniacid&";s:15:"permission_name";s:31:"profile_app_module_link_uniacid";s:4:"icon";s:18:"wi wi-data-synchro";s:12:"displayorder";i:2;s:2:"id";N;s:14:"sub_permission";N;}s:11:"bind_domain";a:9:{s:9:"is_system";i:1;s:10:"is_display";i:0;s:5:"title";s:12:"域名绑定";s:3:"url";s:36:"./index.php?c=profile&a=bind-domain&";s:15:"permission_name";s:19:"profile_bind_domain";s:4:"icon";s:17:"wi wi-bind-domain";s:12:"displayorder";i:1;s:2:"id";N;s:14:"sub_permission";N;}}s:10:"is_display";i:0;}s:10:"statistics";a:3:{s:5:"title";s:6:"统计";s:4:"menu";a:2:{s:14:"statistics_app";a:9:{s:9:"is_system";i:1;s:10:"is_display";i:0;s:5:"title";s:12:"访问统计";s:3:"url";s:31:"./index.php?c=statistics&a=app&";s:15:"permission_name";s:14:"statistics_app";s:4:"icon";s:17:"wi wi-statistical";s:12:"displayorder";i:2;s:2:"id";N;s:14:"sub_permission";N;}s:15:"statistics_fans";a:9:{s:9:"is_system";i:1;s:10:"is_display";i:0;s:5:"title";s:12:"用户统计";s:3:"url";s:32:"./index.php?c=statistics&a=fans&";s:15:"permission_name";s:15:"statistics_fans";s:4:"icon";s:17:"wi wi-statistical";s:12:"displayorder";i:1;s:2:"id";N;s:14:"sub_permission";N;}}s:10:"is_display";i:0;}}s:9:"is_system";b:1;s:10:"is_display";b:1;s:12:"displayorder";i:3;}s:5:"wxapp";a:7:{s:5:"title";s:15:"微信小程序";s:4:"icon";s:19:"wi wi-small-routine";s:3:"url";s:38:"./index.php?c=wxapp&a=display&do=home&";s:7:"section";a:5:{s:14:"wxapp_entrance";a:3:{s:5:"title";s:15:"小程序入口";s:4:"menu";a:1:{s:20:"module_entrance_link";a:9:{s:9:"is_system";i:1;s:10:"is_display";i:0;s:5:"title";s:12:"入口页面";s:3:"url";s:36:"./index.php?c=wxapp&a=entrance-link&";s:15:"permission_name";s:19:"wxapp_entrance_link";s:4:"icon";s:18:"wi wi-data-synchro";s:12:"displayorder";i:1;s:2:"id";N;s:14:"sub_permission";N;}}s:10:"is_display";i:0;}s:15:"platform_module";a:3:{s:5:"title";s:6:"应用";s:4:"menu";a:0:{}s:10:"is_display";b:1;}s:2:"mc";a:3:{s:5:"title";s:6:"粉丝";s:4:"menu";a:1:{s:12:"wxapp_member";a:9:{s:9:"is_system";i:1;s:10:"is_display";i:0;s:5:"title";s:6:"会员";s:3:"url";s:26:"./index.php?c=mc&a=member&";s:15:"permission_name";s:12:"wxapp_member";s:4:"icon";s:10:"wi wi-fans";s:12:"displayorder";i:1;s:2:"id";N;s:14:"sub_permission";N;}}s:10:"is_display";i:0;}s:13:"wxapp_profile";a:2:{s:5:"title";s:6:"配置";s:4:"menu";a:5:{s:17:"wxapp_module_link";a:9:{s:9:"is_system";i:1;s:10:"is_display";i:0;s:5:"title";s:12:"数据同步";s:3:"url";s:42:"./index.php?c=wxapp&a=module-link-uniacid&";s:15:"permission_name";s:25:"wxapp_module_link_uniacid";s:4:"icon";s:18:"wi wi-data-synchro";s:12:"displayorder";i:5;s:2:"id";N;s:14:"sub_permission";N;}s:13:"wxapp_payment";a:9:{s:9:"is_system";i:1;s:10:"is_display";i:0;s:5:"title";s:12:"支付参数";s:3:"url";s:30:"./index.php?c=wxapp&a=payment&";s:15:"permission_name";s:13:"wxapp_payment";s:4:"icon";s:16:"wi wi-appsetting";s:12:"displayorder";i:4;s:2:"id";N;s:14:"sub_permission";N;}s:14:"front_download";a:9:{s:9:"is_system";i:1;s:10:"is_display";i:1;s:5:"title";s:18:"上传微信审核";s:3:"url";s:37:"./index.php?c=wxapp&a=front-download&";s:15:"permission_name";s:20:"wxapp_front_download";s:4:"icon";s:13:"wi wi-examine";s:12:"displayorder";i:3;s:2:"id";N;s:14:"sub_permission";N;}s:17:"parameter_setting";a:9:{s:9:"is_system";i:1;s:10:"is_display";i:0;s:5:"title";s:12:"参数配置";s:3:"url";s:31:"./index.php?c=profile&a=remote&";s:15:"permission_name";s:13:"wxapp_setting";s:4:"icon";s:23:"wi wi-parameter-setting";s:12:"displayorder";i:2;s:2:"id";N;s:14:"sub_permission";N;}s:23:"wxapp_platform_material";a:9:{s:9:"is_system";i:1;s:10:"is_display";i:0;s:5:"title";s:12:"素材管理";s:3:"url";N;s:15:"permission_name";s:23:"wxapp_platform_material";s:4:"icon";N;s:12:"displayorder";i:1;s:2:"id";N;s:14:"sub_permission";a:1:{i:0;a:2:{s:5:"title";s:6:"删除";s:15:"permission_name";s:30:"wxapp_platform_material_delete";}}}}}s:10:"statistics";a:3:{s:5:"title";s:6:"统计";s:4:"menu";a:1:{s:15:"statistics_fans";a:9:{s:9:"is_system";i:1;s:10:"is_display";i:0;s:5:"title";s:12:"访问统计";s:3:"url";s:33:"./index.php?c=wxapp&a=statistics&";s:15:"permission_name";s:15:"statistics_fans";s:4:"icon";s:17:"wi wi-statistical";s:12:"displayorder";i:1;s:2:"id";N;s:14:"sub_permission";N;}}s:10:"is_display";i:0;}}s:9:"is_system";b:1;s:10:"is_display";b:1;s:12:"displayorder";i:4;}s:6:"webapp";a:7:{s:5:"title";s:2:"PC";s:4:"icon";s:8:"wi wi-pc";s:3:"url";s:39:"./index.php?c=webapp&a=home&do=display&";s:7:"section";a:4:{s:15:"platform_module";a:3:{s:5:"title";s:12:"应用模块";s:4:"menu";a:0:{}s:10:"is_display";b:1;}s:2:"mc";a:2:{s:5:"title";s:6:"粉丝";s:4:"menu";a:1:{s:9:"mc_member";a:9:{s:9:"is_system";i:1;s:10:"is_display";i:1;s:5:"title";s:12:"会员管理";s:3:"url";s:26:"./index.php?c=mc&a=member&";s:15:"permission_name";s:9:"mc_member";s:4:"icon";s:10:"wi wi-fans";s:12:"displayorder";i:1;s:2:"id";N;s:14:"sub_permission";N;}}}s:6:"webapp";a:2:{s:5:"title";s:6:"配置";s:4:"menu";a:3:{s:18:"webapp_module_link";a:9:{s:9:"is_system";i:1;s:10:"is_display";i:1;s:5:"title";s:12:"数据同步";s:3:"url";s:43:"./index.php?c=webapp&a=module-link-uniacid&";s:15:"permission_name";s:26:"webapp_module_link_uniacid";s:4:"icon";s:18:"wi wi-data-synchro";s:12:"displayorder";i:3;s:2:"id";N;s:14:"sub_permission";N;}s:14:"webapp_rewrite";a:9:{s:9:"is_system";i:1;s:10:"is_display";i:1;s:5:"title";s:9:"伪静态";s:3:"url";s:31:"./index.php?c=webapp&a=rewrite&";s:15:"permission_name";s:14:"webapp_rewrite";s:4:"icon";s:13:"wi wi-rewrite";s:12:"displayorder";i:2;s:2:"id";N;s:14:"sub_permission";N;}s:18:"webapp_bind_domain";a:9:{s:9:"is_system";i:1;s:10:"is_display";i:1;s:5:"title";s:18:"域名访问设置";s:3:"url";s:35:"./index.php?c=webapp&a=bind-domain&";s:15:"permission_name";s:18:"webapp_bind_domain";s:4:"icon";s:17:"wi wi-bind-domain";s:12:"displayorder";i:1;s:2:"id";N;s:14:"sub_permission";N;}}}s:10:"statistics";a:3:{s:5:"title";s:6:"统计";s:4:"menu";a:1:{s:14:"statistics_app";a:9:{s:9:"is_system";i:1;s:10:"is_display";i:0;s:5:"title";s:12:"访问统计";s:3:"url";s:31:"./index.php?c=statistics&a=app&";s:15:"permission_name";s:14:"statistics_app";s:4:"icon";s:17:"wi wi-statistical";s:12:"displayorder";i:1;s:2:"id";N;s:14:"sub_permission";N;}}s:10:"is_display";i:0;}}s:9:"is_system";b:1;s:10:"is_display";b:1;s:12:"displayorder";i:5;}s:8:"phoneapp";a:7:{s:5:"title";s:3:"APP";s:4:"icon";s:18:"wi wi-white-collar";s:3:"url";s:41:"./index.php?c=phoneapp&a=display&do=home&";s:7:"section";a:2:{s:15:"platform_module";a:3:{s:5:"title";s:6:"应用";s:4:"menu";a:0:{}s:10:"is_display";b:1;}s:16:"phoneapp_profile";a:2:{s:5:"title";s:6:"配置";s:4:"menu";a:1:{s:14:"front_download";a:9:{s:9:"is_system";i:1;s:10:"is_display";i:1;s:5:"title";s:9:"下载APP";s:3:"url";s:40:"./index.php?c=phoneapp&a=front-download&";s:15:"permission_name";s:23:"phoneapp_front_download";s:4:"icon";s:13:"wi wi-examine";s:12:"displayorder";i:1;s:2:"id";N;s:14:"sub_permission";N;}}}}s:9:"is_system";b:1;s:10:"is_display";b:1;s:12:"displayorder";i:6;}s:5:"xzapp";a:7:{s:5:"title";s:9:"熊掌号";s:4:"icon";s:18:"wi wi-white-collar";s:3:"url";s:38:"./index.php?c=xzapp&a=home&do=display&";s:7:"section";a:1:{s:15:"platform_module";a:3:{s:5:"title";s:12:"应用模块";s:4:"menu";a:0:{}s:10:"is_display";b:1;}}s:9:"is_system";b:1;s:10:"is_display";b:1;s:12:"displayorder";i:7;}s:6:"aliapp";a:7:{s:5:"title";s:18:"支付宝小程序";s:4:"icon";s:18:"wi wi-white-collar";s:3:"url";s:40:"./index.php?c=miniapp&a=display&do=home&";s:7:"section";a:1:{s:15:"platform_module";a:3:{s:5:"title";s:6:"应用";s:4:"menu";a:0:{}s:10:"is_display";b:1;}}s:9:"is_system";b:1;s:10:"is_display";b:1;s:12:"displayorder";i:8;}s:6:"module";a:7:{s:5:"title";s:6:"应用";s:4:"icon";s:11:"wi wi-apply";s:3:"url";s:31:"./index.php?c=module&a=display&";s:7:"section";a:0:{}s:9:"is_system";b:1;s:10:"is_display";b:1;s:12:"displayorder";i:9;}s:6:"system";a:7:{s:5:"title";s:6:"系统";s:4:"icon";s:13:"wi wi-setting";s:3:"url";s:39:"./index.php?c=home&a=welcome&do=system&";s:7:"section";a:13:{s:10:"wxplatform";a:2:{s:5:"title";s:9:"公众号";s:4:"menu";a:4:{s:14:"system_account";a:9:{s:9:"is_system";i:1;s:10:"is_display";i:1;s:5:"title";s:16:" 微信公众号";s:3:"url";s:45:"./index.php?c=account&a=manage&account_type=1";s:15:"permission_name";s:14:"system_account";s:4:"icon";s:12:"wi wi-wechat";s:12:"displayorder";i:4;s:2:"id";N;s:14:"sub_permission";a:6:{i:0;a:2:{s:5:"title";s:21:"公众号管理设置";s:15:"permission_name";s:21:"system_account_manage";}i:1;a:2:{s:5:"title";s:15:"添加公众号";s:15:"permission_name";s:19:"system_account_post";}i:2;a:2:{s:5:"title";s:15:"公众号停用";s:15:"permission_name";s:19:"system_account_stop";}i:3;a:2:{s:5:"title";s:18:"公众号回收站";s:15:"permission_name";s:22:"system_account_recycle";}i:4;a:2:{s:5:"title";s:15:"公众号删除";s:15:"permission_name";s:21:"system_account_delete";}i:5;a:2:{s:5:"title";s:15:"公众号恢复";s:15:"permission_name";s:22:"system_account_recover";}}}s:13:"system_module";a:9:{s:9:"is_system";i:1;s:10:"is_display";i:1;s:5:"title";s:15:"公众号应用";s:3:"url";s:60:"./index.php?c=module&a=manage-system&support=account_support";s:15:"permission_name";s:13:"system_module";s:4:"icon";s:14:"wi wi-wx-apply";s:12:"displayorder";i:3;s:2:"id";N;s:14:"sub_permission";N;}s:15:"system_template";a:9:{s:9:"is_system";i:1;s:10:"is_display";i:1;s:5:"title";s:15:"微官网模板";s:3:"url";s:32:"./index.php?c=system&a=template&";s:15:"permission_name";s:15:"system_template";s:4:"icon";s:17:"wi wi-wx-template";s:12:"displayorder";i:2;s:2:"id";N;s:14:"sub_permission";N;}s:15:"system_platform";a:9:{s:9:"is_system";i:1;s:10:"is_display";i:1;s:5:"title";s:19:" 微信开放平台";s:3:"url";s:32:"./index.php?c=system&a=platform&";s:15:"permission_name";s:15:"system_platform";s:4:"icon";s:20:"wi wi-exploitsetting";s:12:"displayorder";i:1;s:2:"id";N;s:14:"sub_permission";N;}}}s:6:"module";a:2:{s:5:"title";s:9:"小程序";s:4:"menu";a:2:{s:12:"system_wxapp";a:9:{s:9:"is_system";i:1;s:10:"is_display";i:1;s:5:"title";s:15:"微信小程序";s:3:"url";s:45:"./index.php?c=account&a=manage&account_type=4";s:15:"permission_name";s:12:"system_wxapp";s:4:"icon";s:11:"wi wi-wxapp";s:12:"displayorder";i:2;s:2:"id";N;s:14:"sub_permission";a:6:{i:0;a:2:{s:5:"title";s:21:"小程序管理设置";s:15:"permission_name";s:19:"system_wxapp_manage";}i:1;a:2:{s:5:"title";s:15:"添加小程序";s:15:"permission_name";s:17:"system_wxapp_post";}i:2;a:2:{s:5:"title";s:15:"小程序停用";s:15:"permission_name";s:17:"system_wxapp_stop";}i:3;a:2:{s:5:"title";s:18:"小程序回收站";s:15:"permission_name";s:20:"system_wxapp_recycle";}i:4;a:2:{s:5:"title";s:15:"小程序删除";s:15:"permission_name";s:19:"system_wxapp_delete";}i:5;a:2:{s:5:"title";s:15:"小程序恢复";s:15:"permission_name";s:20:"system_wxapp_recover";}}}s:19:"system_module_wxapp";a:9:{s:9:"is_system";i:1;s:10:"is_display";i:1;s:5:"title";s:15:"小程序应用";s:3:"url";s:58:"./index.php?c=module&a=manage-system&support=wxapp_support";s:15:"permission_name";s:19:"system_module_wxapp";s:4:"icon";s:17:"wi wi-wxapp-apply";s:12:"displayorder";i:1;s:2:"id";N;s:14:"sub_permission";N;}}}s:7:"welcome";a:3:{s:5:"title";s:12:"系统首页";s:4:"menu";a:1:{s:14:"system_welcome";a:9:{s:9:"is_system";i:1;s:10:"is_display";i:1;s:5:"title";s:18:"系统首页应用";s:3:"url";s:60:"./index.php?c=module&a=manage-system&support=welcome_support";s:15:"permission_name";s:14:"system_welcome";s:4:"icon";s:11:"wi wi-wxapp";s:12:"displayorder";i:1;s:2:"id";N;s:14:"sub_permission";N;}}s:7:"founder";b:1;}s:6:"webapp";a:2:{s:5:"title";s:2:"PC";s:4:"menu";a:2:{s:13:"system_webapp";a:9:{s:9:"is_system";i:1;s:10:"is_display";i:1;s:5:"title";s:2:"PC";s:3:"url";s:45:"./index.php?c=account&a=manage&account_type=5";s:15:"permission_name";s:13:"system_webapp";s:4:"icon";s:8:"wi wi-pc";s:12:"displayorder";i:2;s:2:"id";N;s:14:"sub_permission";a:0:{}}s:20:"system_module_webapp";a:9:{s:9:"is_system";i:1;s:10:"is_display";i:1;s:5:"title";s:8:"PC应用";s:3:"url";s:59:"./index.php?c=module&a=manage-system&support=webapp_support";s:15:"permission_name";s:20:"system_module_webapp";s:4:"icon";s:14:"wi wi-pc-apply";s:12:"displayorder";i:1;s:2:"id";N;s:14:"sub_permission";N;}}}s:8:"phoneapp";a:2:{s:5:"title";s:3:"APP";s:4:"menu";a:2:{s:15:"system_phoneapp";a:9:{s:9:"is_system";i:1;s:10:"is_display";i:1;s:5:"title";s:3:"APP";s:3:"url";s:45:"./index.php?c=account&a=manage&account_type=6";s:15:"permission_name";s:15:"system_phoneapp";s:4:"icon";s:9:"wi wi-app";s:12:"displayorder";i:2;s:2:"id";N;s:14:"sub_permission";a:0:{}}s:22:"system_module_phoneapp";a:9:{s:9:"is_system";i:1;s:10:"is_display";i:1;s:5:"title";s:9:"APP应用";s:3:"url";s:61:"./index.php?c=module&a=manage-system&support=phoneapp_support";s:15:"permission_name";s:22:"system_module_phoneapp";s:4:"icon";s:15:"wi wi-app-apply";s:12:"displayorder";i:1;s:2:"id";N;s:14:"sub_permission";N;}}}s:5:"xzapp";a:2:{s:5:"title";s:9:"熊掌号";s:4:"menu";a:2:{s:12:"system_xzapp";a:9:{s:9:"is_system";i:1;s:10:"is_display";i:1;s:5:"title";s:9:"熊掌号";s:3:"url";s:45:"./index.php?c=account&a=manage&account_type=9";s:15:"permission_name";s:12:"system_xzapp";s:4:"icon";s:11:"wi wi-xzapp";s:12:"displayorder";i:2;s:2:"id";N;s:14:"sub_permission";a:0:{}}s:19:"system_module_xzapp";a:9:{s:9:"is_system";i:1;s:10:"is_display";i:1;s:5:"title";s:15:"熊掌号应用";s:3:"url";s:58:"./index.php?c=module&a=manage-system&support=xzapp_support";s:15:"permission_name";s:19:"system_module_xzapp";s:4:"icon";s:17:"wi wi-xzapp-apply";s:12:"displayorder";i:1;s:2:"id";N;s:14:"sub_permission";N;}}}s:6:"aliapp";a:2:{s:5:"title";s:18:"支付宝小程序";s:4:"menu";a:2:{s:13:"system_aliapp";a:9:{s:9:"is_system";i:1;s:10:"is_display";i:1;s:5:"title";s:18:"支付宝小程序";s:3:"url";s:46:"./index.php?c=account&a=manage&account_type=11";s:15:"permission_name";s:13:"system_aliapp";s:4:"icon";s:12:"wi wi-aliapp";s:12:"displayorder";i:2;s:2:"id";N;s:14:"sub_permission";a:0:{}}s:20:"system_module_aliapp";a:9:{s:9:"is_system";i:1;s:10:"is_display";i:1;s:5:"title";s:24:"支付宝小程序应用";s:3:"url";s:59:"./index.php?c=module&a=manage-system&support=aliapp_support";s:15:"permission_name";s:20:"system_module_aliapp";s:4:"icon";s:18:"wi wi-aliapp-apply";s:12:"displayorder";i:1;s:2:"id";N;s:14:"sub_permission";N;}}}s:4:"user";a:2:{s:5:"title";s:13:"帐户/用户";s:4:"menu";a:3:{s:9:"system_my";a:9:{s:9:"is_system";i:1;s:10:"is_display";i:1;s:5:"title";s:12:"我的帐户";s:3:"url";s:29:"./index.php?c=user&a=profile&";s:15:"permission_name";s:9:"system_my";s:4:"icon";s:10:"wi wi-user";s:12:"displayorder";i:3;s:2:"id";N;s:14:"sub_permission";N;}s:11:"system_user";a:9:{s:9:"is_system";i:1;s:10:"is_display";i:1;s:5:"title";s:12:"用户管理";s:3:"url";s:29:"./index.php?c=user&a=display&";s:15:"permission_name";s:11:"system_user";s:4:"icon";s:16:"wi wi-user-group";s:12:"displayorder";i:2;s:2:"id";N;s:14:"sub_permission";a:7:{i:0;a:2:{s:5:"title";s:12:"编辑用户";s:15:"permission_name";s:16:"system_user_post";}i:1;a:2:{s:5:"title";s:12:"审核用户";s:15:"permission_name";s:17:"system_user_check";}i:2;a:2:{s:5:"title";s:12:"店员管理";s:15:"permission_name";s:17:"system_user_clerk";}i:3;a:2:{s:5:"title";s:15:"用户回收站";s:15:"permission_name";s:19:"system_user_recycle";}i:4;a:2:{s:5:"title";s:18:"用户属性设置";s:15:"permission_name";s:18:"system_user_fields";}i:5;a:2:{s:5:"title";s:31:"用户属性设置-编辑字段";s:15:"permission_name";s:23:"system_user_fields_post";}i:6;a:2:{s:5:"title";s:18:"用户注册设置";s:15:"permission_name";s:23:"system_user_registerset";}}}s:25:"system_user_founder_group";a:9:{s:9:"is_system";i:1;s:10:"is_display";i:1;s:5:"title";s:15:"副创始人组";s:3:"url";s:32:"./index.php?c=founder&a=display&";s:15:"permission_name";s:21:"system_founder_manage";s:4:"icon";s:16:"wi wi-co-founder";s:12:"displayorder";i:1;s:2:"id";N;s:14:"sub_permission";a:6:{i:0;a:2:{s:5:"title";s:18:"添加创始人组";s:15:"permission_name";s:24:"system_founder_group_add";}i:1;a:2:{s:5:"title";s:18:"编辑创始人组";s:15:"permission_name";s:25:"system_founder_group_post";}i:2;a:2:{s:5:"title";s:18:"删除创始人组";s:15:"permission_name";s:24:"system_founder_group_del";}i:3;a:2:{s:5:"title";s:15:"添加创始人";s:15:"permission_name";s:23:"system_founder_user_add";}i:4;a:2:{s:5:"title";s:15:"编辑创始人";s:15:"permission_name";s:24:"system_founder_user_post";}i:5;a:2:{s:5:"title";s:15:"删除创始人";s:15:"permission_name";s:23:"system_founder_user_del";}}}}}s:10:"permission";a:2:{s:5:"title";s:12:"权限管理";s:4:"menu";a:2:{s:19:"system_module_group";a:9:{s:9:"is_system";i:1;s:10:"is_display";i:1;s:5:"title";s:15:"应用权限组";s:3:"url";s:29:"./index.php?c=module&a=group&";s:15:"permission_name";s:19:"system_module_group";s:4:"icon";s:21:"wi wi-appjurisdiction";s:12:"displayorder";i:2;s:2:"id";N;s:14:"sub_permission";a:3:{i:0;a:2:{s:5:"title";s:21:"添加应用权限组";s:15:"permission_name";s:23:"system_module_group_add";}i:1;a:2:{s:5:"title";s:21:"编辑应用权限组";s:15:"permission_name";s:24:"system_module_group_post";}i:2;a:2:{s:5:"title";s:21:"删除应用权限组";s:15:"permission_name";s:23:"system_module_group_del";}}}s:17:"system_user_group";a:9:{s:9:"is_system";i:1;s:10:"is_display";i:1;s:5:"title";s:15:"用户权限组";s:3:"url";s:27:"./index.php?c=user&a=group&";s:15:"permission_name";s:17:"system_user_group";s:4:"icon";s:22:"wi wi-userjurisdiction";s:12:"displayorder";i:1;s:2:"id";N;s:14:"sub_permission";a:3:{i:0;a:2:{s:5:"title";s:15:"添加用户组";s:15:"permission_name";s:21:"system_user_group_add";}i:1;a:2:{s:5:"title";s:15:"编辑用户组";s:15:"permission_name";s:22:"system_user_group_post";}i:2;a:2:{s:5:"title";s:15:"删除用户组";s:15:"permission_name";s:21:"system_user_group_del";}}}}}s:7:"article";a:2:{s:5:"title";s:13:"文章/公告";s:4:"menu";a:2:{s:14:"system_article";a:9:{s:9:"is_system";i:1;s:10:"is_display";i:1;s:5:"title";s:12:"文章管理";s:3:"url";s:29:"./index.php?c=article&a=news&";s:15:"permission_name";s:19:"system_article_news";s:4:"icon";s:13:"wi wi-article";s:12:"displayorder";i:2;s:2:"id";N;s:14:"sub_permission";N;}s:21:"system_article_notice";a:9:{s:9:"is_system";i:1;s:10:"is_display";i:1;s:5:"title";s:12:"公告管理";s:3:"url";s:31:"./index.php?c=article&a=notice&";s:15:"permission_name";s:21:"system_article_notice";s:4:"icon";s:12:"wi wi-notice";s:12:"displayorder";i:1;s:2:"id";N;s:14:"sub_permission";N;}}}s:7:"message";a:2:{s:5:"title";s:12:"消息提醒";s:4:"menu";a:1:{s:21:"system_message_notice";a:9:{s:9:"is_system";i:1;s:10:"is_display";i:1;s:5:"title";s:12:"消息提醒";s:3:"url";s:31:"./index.php?c=message&a=notice&";s:15:"permission_name";s:21:"system_message_notice";s:4:"icon";s:10:"wi wi-bell";s:12:"displayorder";i:1;s:2:"id";N;s:14:"sub_permission";N;}}}s:17:"system_statistics";a:2:{s:5:"title";s:6:"统计";s:4:"menu";a:1:{s:23:"system_account_analysis";a:9:{s:9:"is_system";i:1;s:10:"is_display";i:1;s:5:"title";s:12:"访问统计";s:3:"url";s:35:"./index.php?c=statistics&a=account&";s:15:"permission_name";s:23:"system_account_analysis";s:4:"icon";s:17:"wi wi-statistical";s:12:"displayorder";i:1;s:2:"id";N;s:14:"sub_permission";N;}}}s:5:"cache";a:2:{s:5:"title";s:6:"缓存";s:4:"menu";a:1:{s:26:"system_setting_updatecache";a:9:{s:9:"is_system";i:1;s:10:"is_display";i:1;s:5:"title";s:12:"更新缓存";s:3:"url";s:35:"./index.php?c=system&a=updatecache&";s:15:"permission_name";s:26:"system_setting_updatecache";s:4:"icon";s:12:"wi wi-update";s:12:"displayorder";i:1;s:2:"id";N;s:14:"sub_permission";N;}}}}s:9:"is_system";b:1;s:10:"is_display";b:1;s:12:"displayorder";i:10;}s:4:"site";a:8:{s:5:"title";s:6:"站点";s:4:"icon";s:17:"wi wi-system-site";s:3:"url";s:28:"./index.php?c=system&a=site&";s:7:"section";a:3:{s:7:"setting";a:2:{s:5:"title";s:6:"设置";s:4:"menu";a:9:{s:19:"system_setting_site";a:9:{s:9:"is_system";i:1;s:10:"is_display";i:1;s:5:"title";s:12:"站点设置";s:3:"url";s:28:"./index.php?c=system&a=site&";s:15:"permission_name";s:19:"system_setting_site";s:4:"icon";s:18:"wi wi-site-setting";s:12:"displayorder";i:9;s:2:"id";N;s:14:"sub_permission";N;}s:19:"system_setting_menu";a:9:{s:9:"is_system";i:1;s:10:"is_display";i:1;s:5:"title";s:12:"菜单设置";s:3:"url";s:28:"./index.php?c=system&a=menu&";s:15:"permission_name";s:19:"system_setting_menu";s:4:"icon";s:18:"wi wi-menu-setting";s:12:"displayorder";i:8;s:2:"id";N;s:14:"sub_permission";N;}s:25:"system_setting_attachment";a:9:{s:9:"is_system";i:1;s:10:"is_display";i:1;s:5:"title";s:12:"附件设置";s:3:"url";s:34:"./index.php?c=system&a=attachment&";s:15:"permission_name";s:25:"system_setting_attachment";s:4:"icon";s:16:"wi wi-attachment";s:12:"displayorder";i:7;s:2:"id";N;s:14:"sub_permission";N;}s:25:"system_setting_systeminfo";a:9:{s:9:"is_system";i:1;s:10:"is_display";i:1;s:5:"title";s:12:"系统信息";s:3:"url";s:34:"./index.php?c=system&a=systeminfo&";s:15:"permission_name";s:25:"system_setting_systeminfo";s:4:"icon";s:17:"wi wi-system-info";s:12:"displayorder";i:6;s:2:"id";N;s:14:"sub_permission";N;}s:19:"system_setting_logs";a:9:{s:9:"is_system";i:1;s:10:"is_display";i:1;s:5:"title";s:12:"查看日志";s:3:"url";s:28:"./index.php?c=system&a=logs&";s:15:"permission_name";s:19:"system_setting_logs";s:4:"icon";s:9:"wi wi-log";s:12:"displayorder";i:5;s:2:"id";N;s:14:"sub_permission";N;}s:26:"system_setting_ipwhitelist";a:9:{s:9:"is_system";i:1;s:10:"is_display";i:1;s:5:"title";s:11:"IP白名单";s:3:"url";s:35:"./index.php?c=system&a=ipwhitelist&";s:15:"permission_name";s:26:"system_setting_ipwhitelist";s:4:"icon";s:8:"wi wi-ip";s:12:"displayorder";i:4;s:2:"id";N;s:14:"sub_permission";N;}s:28:"system_setting_sensitiveword";a:9:{s:9:"is_system";i:1;s:10:"is_display";i:1;s:5:"title";s:15:"过滤敏感词";s:3:"url";s:37:"./index.php?c=system&a=sensitiveword&";s:15:"permission_name";s:28:"system_setting_sensitiveword";s:4:"icon";s:15:"wi wi-sensitive";s:12:"displayorder";i:3;s:2:"id";N;s:14:"sub_permission";N;}s:25:"system_setting_thirdlogin";a:9:{s:9:"is_system";i:1;s:10:"is_display";i:1;s:5:"title";s:25:"用户登录/注册设置";s:3:"url";s:33:"./index.php?c=user&a=registerset&";s:15:"permission_name";s:25:"system_setting_thirdlogin";s:4:"icon";s:10:"wi wi-user";s:12:"displayorder";i:2;s:2:"id";N;s:14:"sub_permission";N;}s:20:"system_setting_oauth";a:9:{s:9:"is_system";i:1;s:10:"is_display";i:1;s:5:"title";s:17:"oauth全局设置";s:3:"url";s:29:"./index.php?c=system&a=oauth&";s:15:"permission_name";s:20:"system_setting_oauth";s:4:"icon";s:11:"wi wi-oauth";s:12:"displayorder";i:1;s:2:"id";N;s:14:"sub_permission";N;}}}s:7:"utility";a:2:{s:5:"title";s:12:"常用工具";s:4:"menu";a:5:{s:24:"system_utility_filecheck";a:9:{s:9:"is_system";i:1;s:10:"is_display";i:1;s:5:"title";s:18:"系统文件校验";s:3:"url";s:33:"./index.php?c=system&a=filecheck&";s:15:"permission_name";s:24:"system_utility_filecheck";s:4:"icon";s:10:"wi wi-file";s:12:"displayorder";i:5;s:2:"id";N;s:14:"sub_permission";N;}s:23:"system_utility_optimize";a:9:{s:9:"is_system";i:1;s:10:"is_display";i:1;s:5:"title";s:12:"性能优化";s:3:"url";s:32:"./index.php?c=system&a=optimize&";s:15:"permission_name";s:23:"system_utility_optimize";s:4:"icon";s:14:"wi wi-optimize";s:12:"displayorder";i:4;s:2:"id";N;s:14:"sub_permission";N;}s:23:"system_utility_database";a:9:{s:9:"is_system";i:1;s:10:"is_display";i:1;s:5:"title";s:9:"数据库";s:3:"url";s:32:"./index.php?c=system&a=database&";s:15:"permission_name";s:23:"system_utility_database";s:4:"icon";s:9:"wi wi-sql";s:12:"displayorder";i:3;s:2:"id";N;s:14:"sub_permission";N;}s:19:"system_utility_scan";a:9:{s:9:"is_system";i:1;s:10:"is_display";i:1;s:5:"title";s:12:"木马查杀";s:3:"url";s:28:"./index.php?c=system&a=scan&";s:15:"permission_name";s:19:"system_utility_scan";s:4:"icon";s:12:"wi wi-safety";s:12:"displayorder";i:2;s:2:"id";N;s:14:"sub_permission";N;}s:18:"system_utility_bom";a:9:{s:9:"is_system";i:1;s:10:"is_display";i:1;s:5:"title";s:15:"检测文件BOM";s:3:"url";s:27:"./index.php?c=system&a=bom&";s:15:"permission_name";s:18:"system_utility_bom";s:4:"icon";s:9:"wi wi-bom";s:12:"displayorder";i:1;s:2:"id";N;s:14:"sub_permission";N;}}}s:7:"backjob";a:2:{s:5:"title";s:12:"后台任务";s:4:"menu";a:1:{s:10:"system_job";a:9:{s:9:"is_system";i:1;s:10:"is_display";i:1;s:5:"title";s:12:"后台任务";s:3:"url";s:38:"./index.php?c=system&a=job&do=display&";s:15:"permission_name";s:10:"system_job";s:4:"icon";s:9:"wi wi-job";s:12:"displayorder";i:1;s:2:"id";N;s:14:"sub_permission";N;}}}}s:7:"founder";b:1;s:9:"is_system";b:1;s:10:"is_display";b:1;s:12:"displayorder";i:11;}s:5:"store";a:7:{s:5:"title";s:6:"商城";s:4:"icon";s:11:"wi wi-store";s:3:"url";s:43:"./index.php?c=home&a=welcome&do=ext&m=store";s:7:"section";a:0:{}s:9:"is_system";b:1;s:10:"is_display";b:1;s:12:"displayorder";i:12;}}'),
('we7:user_modules:1', 'a:12:{s:5:"store";s:3:"all";s:6:"wxcard";s:3:"all";s:5:"chats";s:3:"all";s:5:"voice";s:3:"all";s:5:"video";s:3:"all";s:6:"images";s:3:"all";s:6:"custom";s:3:"all";s:8:"recharge";s:3:"all";s:7:"userapi";s:3:"all";s:5:"music";s:3:"all";s:4:"news";s:3:"all";s:5:"basic";s:3:"all";}'),
('we7:module_info:store', 'a:32:{s:3:"mid";s:2:"12";s:4:"name";s:5:"store";s:4:"type";s:8:"business";s:5:"title";s:12:"站内商城";s:7:"version";s:3:"1.0";s:7:"ability";s:12:"站内商城";s:11:"description";s:12:"站内商城";s:6:"author";s:13:"WeEngine Team";s:3:"url";s:18:"http://www.we7.cc/";s:8:"settings";s:1:"0";s:10:"subscribes";s:0:"";s:7:"handles";s:0:"";s:12:"isrulefields";s:1:"0";s:8:"issystem";s:1:"1";s:6:"target";s:1:"0";s:6:"iscard";s:1:"0";s:11:"permissions";s:0:"";s:13:"title_initial";s:0:"";s:13:"wxapp_support";s:1:"1";s:15:"welcome_support";s:1:"1";s:10:"oauth_type";s:1:"1";s:14:"webapp_support";s:1:"1";s:16:"phoneapp_support";s:1:"0";s:15:"account_support";s:1:"2";s:13:"xzapp_support";s:1:"0";s:11:"app_support";s:1:"0";s:14:"aliapp_support";s:1:"0";s:9:"isdisplay";i:1;s:4:"logo";s:51:"http://127.0.0.1/addons/store/icon.jpg?v=1566289328";s:7:"preview";s:41:"http://127.0.0.1/addons/store/preview.jpg";s:11:"main_module";b:0;s:11:"plugin_list";a:0:{}}'),
('we7:module_info:wxcard', 'a:32:{s:3:"mid";s:2:"11";s:4:"name";s:6:"wxcard";s:4:"type";s:6:"system";s:5:"title";s:18:"微信卡券回复";s:7:"version";s:3:"1.0";s:7:"ability";s:18:"微信卡券回复";s:11:"description";s:18:"微信卡券回复";s:6:"author";s:13:"WeEngine Team";s:3:"url";s:18:"http://www.we7.cc/";s:8:"settings";s:1:"0";s:10:"subscribes";s:0:"";s:7:"handles";s:0:"";s:12:"isrulefields";s:1:"1";s:8:"issystem";s:1:"1";s:6:"target";s:1:"0";s:6:"iscard";s:1:"0";s:11:"permissions";s:0:"";s:13:"title_initial";s:0:"";s:13:"wxapp_support";s:1:"1";s:15:"welcome_support";s:1:"1";s:10:"oauth_type";s:1:"1";s:14:"webapp_support";s:1:"1";s:16:"phoneapp_support";s:1:"0";s:15:"account_support";s:1:"2";s:13:"xzapp_support";s:1:"0";s:11:"app_support";s:1:"0";s:14:"aliapp_support";s:1:"0";s:9:"isdisplay";i:1;s:4:"logo";s:52:"http://127.0.0.1/addons/wxcard/icon.jpg?v=1566289328";s:7:"preview";s:42:"http://127.0.0.1/addons/wxcard/preview.jpg";s:11:"main_module";b:0;s:11:"plugin_list";a:0:{}}'),
('we7:module_info:chats', 'a:32:{s:3:"mid";s:2:"10";s:4:"name";s:5:"chats";s:4:"type";s:6:"system";s:5:"title";s:18:"发送客服消息";s:7:"version";s:3:"1.0";s:7:"ability";s:77:"公众号可以在粉丝最后发送消息的48小时内无限制发送消息";s:11:"description";s:0:"";s:6:"author";s:13:"WeEngine Team";s:3:"url";s:18:"http://www.we7.cc/";s:8:"settings";s:1:"0";s:10:"subscribes";s:0:"";s:7:"handles";s:0:"";s:12:"isrulefields";s:1:"0";s:8:"issystem";s:1:"1";s:6:"target";s:1:"0";s:6:"iscard";s:1:"0";s:11:"permissions";s:0:"";s:13:"title_initial";s:0:"";s:13:"wxapp_support";s:1:"1";s:15:"welcome_support";s:1:"1";s:10:"oauth_type";s:1:"1";s:14:"webapp_support";s:1:"1";s:16:"phoneapp_support";s:1:"0";s:15:"account_support";s:1:"2";s:13:"xzapp_support";s:1:"0";s:11:"app_support";s:1:"0";s:14:"aliapp_support";s:1:"0";s:9:"isdisplay";i:1;s:4:"logo";s:51:"http://127.0.0.1/addons/chats/icon.jpg?v=1566289328";s:7:"preview";s:41:"http://127.0.0.1/addons/chats/preview.jpg";s:11:"main_module";b:0;s:11:"plugin_list";a:0:{}}'),
('we7:module_info:voice', 'a:32:{s:3:"mid";s:1:"9";s:4:"name";s:5:"voice";s:4:"type";s:6:"system";s:5:"title";s:18:"基本语音回复";s:7:"version";s:3:"1.0";s:7:"ability";s:18:"提供语音回复";s:11:"description";s:132:"在回复规则中可选择具有语音的回复内容，并根据用户所设置的特定关键字精准的返回给粉丝语音。";s:6:"author";s:13:"WeEngine Team";s:3:"url";s:18:"http://www.we7.cc/";s:8:"settings";s:1:"0";s:10:"subscribes";s:0:"";s:7:"handles";s:0:"";s:12:"isrulefields";s:1:"1";s:8:"issystem";s:1:"1";s:6:"target";s:1:"0";s:6:"iscard";s:1:"0";s:11:"permissions";s:0:"";s:13:"title_initial";s:0:"";s:13:"wxapp_support";s:1:"1";s:15:"welcome_support";s:1:"1";s:10:"oauth_type";s:1:"1";s:14:"webapp_support";s:1:"1";s:16:"phoneapp_support";s:1:"0";s:15:"account_support";s:1:"2";s:13:"xzapp_support";s:1:"0";s:11:"app_support";s:1:"0";s:14:"aliapp_support";s:1:"0";s:9:"isdisplay";i:1;s:4:"logo";s:51:"http://127.0.0.1/addons/voice/icon.jpg?v=1566289328";s:7:"preview";s:41:"http://127.0.0.1/addons/voice/preview.jpg";s:11:"main_module";b:0;s:11:"plugin_list";a:0:{}}'),
('we7:module_info:video', 'a:32:{s:3:"mid";s:1:"8";s:4:"name";s:5:"video";s:4:"type";s:6:"system";s:5:"title";s:18:"基本视频回复";s:7:"version";s:3:"1.0";s:7:"ability";s:18:"提供图片回复";s:11:"description";s:132:"在回复规则中可选择具有视频的回复内容，并根据用户所设置的特定关键字精准的返回给粉丝视频。";s:6:"author";s:13:"WeEngine Team";s:3:"url";s:18:"http://www.we7.cc/";s:8:"settings";s:1:"0";s:10:"subscribes";s:0:"";s:7:"handles";s:0:"";s:12:"isrulefields";s:1:"1";s:8:"issystem";s:1:"1";s:6:"target";s:1:"0";s:6:"iscard";s:1:"0";s:11:"permissions";s:0:"";s:13:"title_initial";s:0:"";s:13:"wxapp_support";s:1:"1";s:15:"welcome_support";s:1:"1";s:10:"oauth_type";s:1:"1";s:14:"webapp_support";s:1:"1";s:16:"phoneapp_support";s:1:"0";s:15:"account_support";s:1:"2";s:13:"xzapp_support";s:1:"0";s:11:"app_support";s:1:"0";s:14:"aliapp_support";s:1:"0";s:9:"isdisplay";i:1;s:4:"logo";s:51:"http://127.0.0.1/addons/video/icon.jpg?v=1566289328";s:7:"preview";s:41:"http://127.0.0.1/addons/video/preview.jpg";s:11:"main_module";b:0;s:11:"plugin_list";a:0:{}}'),
('we7:module_info:images', 'a:32:{s:3:"mid";s:1:"7";s:4:"name";s:6:"images";s:4:"type";s:6:"system";s:5:"title";s:18:"基本图片回复";s:7:"version";s:3:"1.0";s:7:"ability";s:18:"提供图片回复";s:11:"description";s:132:"在回复规则中可选择具有图片的回复内容，并根据用户所设置的特定关键字精准的返回给粉丝图片。";s:6:"author";s:13:"WeEngine Team";s:3:"url";s:18:"http://www.we7.cc/";s:8:"settings";s:1:"0";s:10:"subscribes";s:0:"";s:7:"handles";s:0:"";s:12:"isrulefields";s:1:"1";s:8:"issystem";s:1:"1";s:6:"target";s:1:"0";s:6:"iscard";s:1:"0";s:11:"permissions";s:0:"";s:13:"title_initial";s:0:"";s:13:"wxapp_support";s:1:"1";s:15:"welcome_support";s:1:"1";s:10:"oauth_type";s:1:"1";s:14:"webapp_support";s:1:"1";s:16:"phoneapp_support";s:1:"0";s:15:"account_support";s:1:"2";s:13:"xzapp_support";s:1:"0";s:11:"app_support";s:1:"0";s:14:"aliapp_support";s:1:"0";s:9:"isdisplay";i:1;s:4:"logo";s:52:"http://127.0.0.1/addons/images/icon.jpg?v=1566289328";s:7:"preview";s:42:"http://127.0.0.1/addons/images/preview.jpg";s:11:"main_module";b:0;s:11:"plugin_list";a:0:{}}'),
('we7:module_info:custom', 'a:32:{s:3:"mid";s:1:"6";s:4:"name";s:6:"custom";s:4:"type";s:6:"system";s:5:"title";s:15:"多客服转接";s:7:"version";s:5:"1.0.0";s:7:"ability";s:36:"用来接入腾讯的多客服系统";s:11:"description";s:0:"";s:6:"author";s:13:"WeEngine Team";s:3:"url";s:17:"http://bbs.we7.cc";s:8:"settings";s:1:"0";s:10:"subscribes";a:0:{}s:7:"handles";a:6:{i:0;s:5:"image";i:1;s:5:"voice";i:2;s:5:"video";i:3;s:8:"location";i:4;s:4:"link";i:5;s:4:"text";}s:12:"isrulefields";s:1:"1";s:8:"issystem";s:1:"1";s:6:"target";s:1:"0";s:6:"iscard";s:1:"0";s:11:"permissions";s:0:"";s:13:"title_initial";s:0:"";s:13:"wxapp_support";s:1:"1";s:15:"welcome_support";s:1:"1";s:10:"oauth_type";s:1:"1";s:14:"webapp_support";s:1:"1";s:16:"phoneapp_support";s:1:"0";s:15:"account_support";s:1:"2";s:13:"xzapp_support";s:1:"0";s:11:"app_support";s:1:"0";s:14:"aliapp_support";s:1:"0";s:9:"isdisplay";i:1;s:4:"logo";s:52:"http://127.0.0.1/addons/custom/icon.jpg?v=1566289328";s:7:"preview";s:42:"http://127.0.0.1/addons/custom/preview.jpg";s:11:"main_module";b:0;s:11:"plugin_list";a:0:{}}'),
('we7:module_info:recharge', 'a:32:{s:3:"mid";s:1:"5";s:4:"name";s:8:"recharge";s:4:"type";s:6:"system";s:5:"title";s:24:"会员中心充值模块";s:7:"version";s:3:"1.0";s:7:"ability";s:24:"提供会员充值功能";s:11:"description";s:0:"";s:6:"author";s:13:"WeEngine Team";s:3:"url";s:18:"http://www.we7.cc/";s:8:"settings";s:1:"0";s:10:"subscribes";s:0:"";s:7:"handles";s:0:"";s:12:"isrulefields";s:1:"0";s:8:"issystem";s:1:"1";s:6:"target";s:1:"0";s:6:"iscard";s:1:"0";s:11:"permissions";s:0:"";s:13:"title_initial";s:0:"";s:13:"wxapp_support";s:1:"1";s:15:"welcome_support";s:1:"1";s:10:"oauth_type";s:1:"1";s:14:"webapp_support";s:1:"1";s:16:"phoneapp_support";s:1:"0";s:15:"account_support";s:1:"2";s:13:"xzapp_support";s:1:"0";s:11:"app_support";s:1:"0";s:14:"aliapp_support";s:1:"0";s:9:"isdisplay";i:1;s:4:"logo";s:54:"http://127.0.0.1/addons/recharge/icon.jpg?v=1566289328";s:7:"preview";s:44:"http://127.0.0.1/addons/recharge/preview.jpg";s:11:"main_module";b:0;s:11:"plugin_list";a:0:{}}'),
('we7:module_info:userapi', 'a:32:{s:3:"mid";s:1:"4";s:4:"name";s:7:"userapi";s:4:"type";s:6:"system";s:5:"title";s:21:"自定义接口回复";s:7:"version";s:3:"1.1";s:7:"ability";s:33:"更方便的第三方接口设置";s:11:"description";s:141:"自定义接口又称第三方接口，可以让开发者更方便的接入微擎系统，高效的与微信公众平台进行对接整合。";s:6:"author";s:13:"WeEngine Team";s:3:"url";s:18:"http://www.we7.cc/";s:8:"settings";s:1:"0";s:10:"subscribes";s:0:"";s:7:"handles";s:0:"";s:12:"isrulefields";s:1:"1";s:8:"issystem";s:1:"1";s:6:"target";s:1:"0";s:6:"iscard";s:1:"0";s:11:"permissions";s:0:"";s:13:"title_initial";s:0:"";s:13:"wxapp_support";s:1:"1";s:15:"welcome_support";s:1:"1";s:10:"oauth_type";s:1:"1";s:14:"webapp_support";s:1:"1";s:16:"phoneapp_support";s:1:"0";s:15:"account_support";s:1:"2";s:13:"xzapp_support";s:1:"0";s:11:"app_support";s:1:"0";s:14:"aliapp_support";s:1:"0";s:9:"isdisplay";i:1;s:4:"logo";s:53:"http://127.0.0.1/addons/userapi/icon.jpg?v=1566289328";s:7:"preview";s:43:"http://127.0.0.1/addons/userapi/preview.jpg";s:11:"main_module";b:0;s:11:"plugin_list";a:0:{}}'),
('we7:module_info:music', 'a:32:{s:3:"mid";s:1:"3";s:4:"name";s:5:"music";s:4:"type";s:6:"system";s:5:"title";s:18:"基本音乐回复";s:7:"version";s:3:"1.0";s:7:"ability";s:39:"提供语音、音乐等音频类回复";s:11:"description";s:183:"在回复规则中可选择具有语音、音乐等音频类的回复内容，并根据用户所设置的特定关键字精准的返回给粉丝，实现一问一答得简单对话。";s:6:"author";s:13:"WeEngine Team";s:3:"url";s:18:"http://www.we7.cc/";s:8:"settings";s:1:"0";s:10:"subscribes";s:0:"";s:7:"handles";s:0:"";s:12:"isrulefields";s:1:"1";s:8:"issystem";s:1:"1";s:6:"target";s:1:"0";s:6:"iscard";s:1:"0";s:11:"permissions";s:0:"";s:13:"title_initial";s:0:"";s:13:"wxapp_support";s:1:"1";s:15:"welcome_support";s:1:"1";s:10:"oauth_type";s:1:"1";s:14:"webapp_support";s:1:"1";s:16:"phoneapp_support";s:1:"0";s:15:"account_support";s:1:"2";s:13:"xzapp_support";s:1:"0";s:11:"app_support";s:1:"0";s:14:"aliapp_support";s:1:"0";s:9:"isdisplay";i:1;s:4:"logo";s:51:"http://127.0.0.1/addons/music/icon.jpg?v=1566289328";s:7:"preview";s:41:"http://127.0.0.1/addons/music/preview.jpg";s:11:"main_module";b:0;s:11:"plugin_list";a:0:{}}'),
('we7:module_info:news', 'a:32:{s:3:"mid";s:1:"2";s:4:"name";s:4:"news";s:4:"type";s:6:"system";s:5:"title";s:24:"基本混合图文回复";s:7:"version";s:3:"1.0";s:7:"ability";s:33:"为你提供生动的图文资讯";s:11:"description";s:272:"一问一答得简单对话, 但是回复内容包括图片文字等更生动的媒体内容. 当访客的对话语句中包含指定关键字, 或对话语句完全等于特定关键字, 或符合某些特定的格式时. 系统自动应答设定好的图文回复内容.";s:6:"author";s:13:"WeEngine Team";s:3:"url";s:18:"http://www.we7.cc/";s:8:"settings";s:1:"0";s:10:"subscribes";s:0:"";s:7:"handles";s:0:"";s:12:"isrulefields";s:1:"1";s:8:"issystem";s:1:"1";s:6:"target";s:1:"0";s:6:"iscard";s:1:"0";s:11:"permissions";s:0:"";s:13:"title_initial";s:0:"";s:13:"wxapp_support";s:1:"1";s:15:"welcome_support";s:1:"1";s:10:"oauth_type";s:1:"1";s:14:"webapp_support";s:1:"1";s:16:"phoneapp_support";s:1:"0";s:15:"account_support";s:1:"2";s:13:"xzapp_support";s:1:"0";s:11:"app_support";s:1:"0";s:14:"aliapp_support";s:1:"0";s:9:"isdisplay";i:1;s:4:"logo";s:50:"http://127.0.0.1/addons/news/icon.jpg?v=1566289328";s:7:"preview";s:40:"http://127.0.0.1/addons/news/preview.jpg";s:11:"main_module";b:0;s:11:"plugin_list";a:0:{}}'),
('we7:module_info:basic', 'a:32:{s:3:"mid";s:1:"1";s:4:"name";s:5:"basic";s:4:"type";s:6:"system";s:5:"title";s:18:"基本文字回复";s:7:"version";s:3:"1.0";s:7:"ability";s:24:"和您进行简单对话";s:11:"description";s:201:"一问一答得简单对话. 当访客的对话语句中包含指定关键字, 或对话语句完全等于特定关键字, 或符合某些特定的格式时. 系统自动应答设定好的回复内容.";s:6:"author";s:13:"WeEngine Team";s:3:"url";s:18:"http://www.we7.cc/";s:8:"settings";s:1:"0";s:10:"subscribes";s:0:"";s:7:"handles";s:0:"";s:12:"isrulefields";s:1:"1";s:8:"issystem";s:1:"1";s:6:"target";s:1:"0";s:6:"iscard";s:1:"0";s:11:"permissions";s:0:"";s:13:"title_initial";s:0:"";s:13:"wxapp_support";s:1:"1";s:15:"welcome_support";s:1:"1";s:10:"oauth_type";s:1:"1";s:14:"webapp_support";s:1:"1";s:16:"phoneapp_support";s:1:"0";s:15:"account_support";s:1:"2";s:13:"xzapp_support";s:1:"0";s:11:"app_support";s:1:"0";s:14:"aliapp_support";s:1:"0";s:9:"isdisplay";i:1;s:4:"logo";s:51:"http://127.0.0.1/addons/basic/icon.jpg?v=1566289328";s:7:"preview";s:41:"http://127.0.0.1/addons/basic/preview.jpg";s:11:"main_module";b:0;s:11:"plugin_list";a:0:{}}');

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_core_cron`
--

CREATE TABLE IF NOT EXISTS `wqwdb_core_cron` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `cloudid` int(10) unsigned NOT NULL,
  `module` varchar(50) NOT NULL,
  `uniacid` int(10) unsigned NOT NULL,
  `type` tinyint(3) unsigned NOT NULL,
  `name` varchar(50) NOT NULL,
  `filename` varchar(50) NOT NULL,
  `lastruntime` int(10) unsigned NOT NULL,
  `nextruntime` int(10) unsigned NOT NULL,
  `weekday` tinyint(3) NOT NULL,
  `day` tinyint(3) NOT NULL,
  `hour` tinyint(3) NOT NULL,
  `minute` varchar(255) NOT NULL,
  `extra` varchar(5000) NOT NULL,
  `status` tinyint(3) unsigned NOT NULL,
  `createtime` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `createtime` (`createtime`),
  KEY `nextruntime` (`nextruntime`),
  KEY `uniacid` (`uniacid`),
  KEY `cloudid` (`cloudid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_core_cron_record`
--

CREATE TABLE IF NOT EXISTS `wqwdb_core_cron_record` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `uniacid` int(10) unsigned NOT NULL,
  `module` varchar(50) NOT NULL,
  `type` varchar(50) NOT NULL,
  `tid` int(10) unsigned NOT NULL,
  `note` varchar(500) NOT NULL,
  `tag` varchar(5000) NOT NULL,
  `createtime` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `uniacid` (`uniacid`),
  KEY `tid` (`tid`),
  KEY `module` (`module`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_core_job`
--

CREATE TABLE IF NOT EXISTS `wqwdb_core_job` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type` tinyint(4) NOT NULL,
  `uniacid` int(11) NOT NULL,
  `payload` varchar(255) NOT NULL,
  `status` tinyint(3) NOT NULL,
  `title` varchar(22) NOT NULL,
  `handled` int(11) NOT NULL,
  `total` int(11) NOT NULL,
  `createtime` int(11) NOT NULL,
  `updatetime` int(11) NOT NULL,
  `endtime` int(11) NOT NULL,
  `isdeleted` tinyint(1) DEFAULT NULL,
  `uid` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=2 ;

--
-- 转存表中的数据 `wqwdb_core_job`
--

INSERT INTO `wqwdb_core_job` (`id`, `type`, `uniacid`, `payload`, `status`, `title`, `handled`, `total`, `createtime`, `updatetime`, `endtime`, `isdeleted`, `uid`) VALUES
(1, 10, 1, '', 1, '删除微擎团队的素材数据', 0, 0, 1566287547, 1566287547, 1566287547, 0, 1);

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_core_menu`
--

CREATE TABLE IF NOT EXISTS `wqwdb_core_menu` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `pid` int(10) unsigned NOT NULL,
  `title` varchar(20) NOT NULL,
  `name` varchar(20) NOT NULL,
  `url` varchar(255) NOT NULL,
  `append_title` varchar(30) NOT NULL,
  `append_url` varchar(255) NOT NULL,
  `displayorder` tinyint(3) unsigned NOT NULL,
  `type` varchar(15) NOT NULL,
  `is_display` tinyint(3) unsigned NOT NULL,
  `is_system` tinyint(3) unsigned NOT NULL,
  `permission_name` varchar(50) NOT NULL,
  `group_name` varchar(30) NOT NULL,
  `icon` varchar(20) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=2 ;

--
-- 转存表中的数据 `wqwdb_core_menu`
--

INSERT INTO `wqwdb_core_menu` (`id`, `pid`, `title`, `name`, `url`, `append_title`, `append_url`, `displayorder`, `type`, `is_display`, `is_system`, `permission_name`, `group_name`, `icon`) VALUES
(1, 0, '', '', '', '', '', 0, '', 0, 1, 'help', 'frame', '');

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_core_paylog`
--

CREATE TABLE IF NOT EXISTS `wqwdb_core_paylog` (
  `plid` bigint(11) unsigned NOT NULL AUTO_INCREMENT,
  `type` varchar(20) NOT NULL,
  `uniacid` int(11) NOT NULL,
  `acid` int(10) NOT NULL,
  `openid` varchar(40) NOT NULL,
  `uniontid` varchar(64) NOT NULL,
  `tid` varchar(128) NOT NULL,
  `fee` decimal(10,2) NOT NULL,
  `status` tinyint(4) NOT NULL,
  `module` varchar(50) NOT NULL,
  `tag` varchar(2000) NOT NULL,
  `is_usecard` tinyint(3) unsigned NOT NULL,
  `card_type` tinyint(3) unsigned NOT NULL,
  `card_id` varchar(50) NOT NULL,
  `card_fee` decimal(10,2) unsigned NOT NULL,
  `encrypt_code` varchar(100) NOT NULL,
  PRIMARY KEY (`plid`),
  KEY `idx_openid` (`openid`),
  KEY `idx_tid` (`tid`),
  KEY `idx_uniacid` (`uniacid`),
  KEY `uniontid` (`uniontid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_core_performance`
--

CREATE TABLE IF NOT EXISTS `wqwdb_core_performance` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `type` tinyint(1) NOT NULL,
  `runtime` varchar(10) NOT NULL,
  `runurl` varchar(512) NOT NULL,
  `runsql` varchar(512) NOT NULL,
  `createtime` int(10) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_core_queue`
--

CREATE TABLE IF NOT EXISTS `wqwdb_core_queue` (
  `qid` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `uniacid` int(10) unsigned NOT NULL,
  `acid` int(10) unsigned NOT NULL,
  `message` varchar(2000) NOT NULL,
  `params` varchar(1000) NOT NULL,
  `keyword` varchar(1000) NOT NULL,
  `response` varchar(2000) NOT NULL,
  `module` varchar(50) NOT NULL,
  `type` tinyint(3) unsigned NOT NULL,
  `dateline` int(10) unsigned NOT NULL,
  PRIMARY KEY (`qid`),
  KEY `uniacid` (`uniacid`,`acid`),
  KEY `module` (`module`),
  KEY `dateline` (`dateline`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_core_refundlog`
--

CREATE TABLE IF NOT EXISTS `wqwdb_core_refundlog` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `uniacid` int(11) NOT NULL,
  `refund_uniontid` varchar(64) NOT NULL,
  `reason` varchar(80) NOT NULL,
  `uniontid` varchar(64) NOT NULL,
  `fee` decimal(10,2) NOT NULL,
  `status` int(2) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `refund_uniontid` (`refund_uniontid`),
  KEY `uniontid` (`uniontid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_core_resource`
--

CREATE TABLE IF NOT EXISTS `wqwdb_core_resource` (
  `mid` int(11) NOT NULL AUTO_INCREMENT,
  `uniacid` int(10) unsigned NOT NULL,
  `media_id` varchar(100) NOT NULL,
  `trunk` int(10) unsigned NOT NULL,
  `type` varchar(10) NOT NULL,
  `dateline` int(10) unsigned NOT NULL,
  PRIMARY KEY (`mid`),
  KEY `acid` (`uniacid`),
  KEY `type` (`type`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_core_sendsms_log`
--

CREATE TABLE IF NOT EXISTS `wqwdb_core_sendsms_log` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `uniacid` int(10) unsigned NOT NULL,
  `mobile` varchar(11) NOT NULL,
  `content` varchar(255) NOT NULL,
  `result` varchar(255) NOT NULL,
  `createtime` int(11) unsigned NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_core_sessions`
--

CREATE TABLE IF NOT EXISTS `wqwdb_core_sessions` (
  `sid` char(32) NOT NULL,
  `uniacid` int(10) unsigned NOT NULL,
  `openid` varchar(50) NOT NULL,
  `data` varchar(5000) NOT NULL,
  `expiretime` int(10) unsigned NOT NULL,
  PRIMARY KEY (`sid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_core_settings`
--

CREATE TABLE IF NOT EXISTS `wqwdb_core_settings` (
  `key` varchar(200) NOT NULL,
  `value` text NOT NULL,
  PRIMARY KEY (`key`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- 转存表中的数据 `wqwdb_core_settings`
--

INSERT INTO `wqwdb_core_settings` (`key`, `value`) VALUES
('copyright', 'a:37:{s:6:"status";i:0;s:10:"verifycode";N;s:6:"reason";s:0:"";s:8:"sitename";s:0:"";s:3:"url";s:7:"http://";s:8:"statcode";s:0:"";s:10:"footerleft";s:0:"";s:11:"footerright";s:0:"";s:4:"icon";s:0:"";s:5:"flogo";s:0:"";s:14:"background_img";s:48:"images/global/rIUBUNKni4DKBKcS88cS1D4i3KIIkG.jpg";s:6:"slides";s:2:"N;";s:6:"notice";s:0:"";s:5:"blogo";s:0:"";s:8:"baidumap";a:2:{s:3:"lng";s:0:"";s:3:"lat";s:0:"";}s:7:"company";s:0:"";s:14:"companyprofile";s:0:"";s:7:"address";s:0:"";s:6:"person";s:0:"";s:5:"phone";s:0:"";s:2:"qq";s:0:"";s:5:"email";s:0:"";s:8:"keywords";s:0:"";s:11:"description";s:0:"";s:12:"showhomepage";i:0;s:13:"leftmenufixed";i:0;s:13:"mobile_status";N;s:10:"login_type";N;s:10:"log_status";i:0;s:14:"develop_status";i:0;s:3:"icp";s:0:"";s:8:"sms_name";s:0:"";s:12:"sms_password";s:0:"";s:8:"sms_sign";s:0:"";s:4:"bind";N;s:12:"welcome_link";N;s:10:"oauth_bind";N;}'),
('authmode', 'i:1;'),
('close', 'a:2:{s:6:"status";s:1:"0";s:6:"reason";s:0:"";}'),
('register', 'a:4:{s:4:"open";i:1;s:6:"verify";i:0;s:4:"code";i:1;s:7:"groupid";i:1;}'),
('cloudip', 'a:2:{s:2:"ip";s:15:"132.232.105.191";s:6:"expire";i:1566291426;}'),
('basic', 'a:1:{s:8:"template";s:5:"black";}');

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_coupon_location`
--

CREATE TABLE IF NOT EXISTS `wqwdb_coupon_location` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `uniacid` int(10) unsigned NOT NULL,
  `acid` int(10) unsigned NOT NULL,
  `sid` int(10) unsigned NOT NULL,
  `location_id` int(10) unsigned NOT NULL,
  `business_name` varchar(50) NOT NULL,
  `branch_name` varchar(50) NOT NULL,
  `category` varchar(255) NOT NULL,
  `province` varchar(15) NOT NULL,
  `city` varchar(15) NOT NULL,
  `district` varchar(15) NOT NULL,
  `address` varchar(50) NOT NULL,
  `longitude` varchar(15) NOT NULL,
  `latitude` varchar(15) NOT NULL,
  `telephone` varchar(20) NOT NULL,
  `photo_list` varchar(10000) NOT NULL,
  `avg_price` int(10) unsigned NOT NULL,
  `open_time` varchar(50) NOT NULL,
  `recommend` varchar(255) NOT NULL,
  `special` varchar(255) NOT NULL,
  `introduction` varchar(255) NOT NULL,
  `offset_type` tinyint(3) unsigned NOT NULL,
  `status` tinyint(3) unsigned NOT NULL,
  `message` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `uniacid` (`uniacid`,`acid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_cover_reply`
--

CREATE TABLE IF NOT EXISTS `wqwdb_cover_reply` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `uniacid` int(10) unsigned NOT NULL,
  `multiid` int(10) unsigned NOT NULL,
  `rid` int(10) unsigned NOT NULL,
  `module` varchar(30) NOT NULL,
  `do` varchar(30) NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` varchar(255) NOT NULL,
  `thumb` varchar(255) NOT NULL,
  `url` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `rid` (`rid`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=3 ;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_custom_reply`
--

CREATE TABLE IF NOT EXISTS `wqwdb_custom_reply` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `rid` int(10) unsigned NOT NULL,
  `start1` int(10) NOT NULL,
  `end1` int(10) NOT NULL,
  `start2` int(10) NOT NULL,
  `end2` int(10) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `rid` (`rid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_images_reply`
--

CREATE TABLE IF NOT EXISTS `wqwdb_images_reply` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `rid` int(10) unsigned NOT NULL,
  `title` varchar(50) NOT NULL,
  `description` varchar(255) NOT NULL,
  `mediaid` varchar(255) NOT NULL,
  `createtime` int(10) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `rid` (`rid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_job`
--

CREATE TABLE IF NOT EXISTS `wqwdb_job` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type` tinyint(4) NOT NULL,
  `uniacid` int(11) NOT NULL,
  `payload` varchar(255) NOT NULL,
  `status` tinyint(3) NOT NULL,
  `title` varchar(22) NOT NULL,
  `handled` int(11) NOT NULL,
  `total` int(11) NOT NULL,
  `createtime` int(11) NOT NULL,
  `updatetime` int(11) NOT NULL,
  `endtime` int(11) NOT NULL,
  `uid` int(11) DEFAULT NULL,
  `isdeleted` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_mc_cash_record`
--

CREATE TABLE IF NOT EXISTS `wqwdb_mc_cash_record` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `uniacid` int(10) unsigned NOT NULL,
  `uid` int(10) unsigned NOT NULL,
  `clerk_id` int(10) unsigned NOT NULL,
  `store_id` int(10) unsigned NOT NULL,
  `clerk_type` tinyint(3) unsigned NOT NULL,
  `fee` decimal(10,2) unsigned NOT NULL,
  `final_fee` decimal(10,2) unsigned NOT NULL,
  `credit1` int(10) unsigned NOT NULL,
  `credit1_fee` decimal(10,2) unsigned NOT NULL,
  `credit2` decimal(10,2) unsigned NOT NULL,
  `cash` decimal(10,2) unsigned NOT NULL,
  `return_cash` decimal(10,2) unsigned NOT NULL,
  `final_cash` decimal(10,2) unsigned NOT NULL,
  `remark` varchar(255) NOT NULL,
  `createtime` int(10) unsigned NOT NULL,
  `trade_type` varchar(20) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `uniacid` (`uniacid`),
  KEY `uid` (`uid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_mc_chats_record`
--

CREATE TABLE IF NOT EXISTS `wqwdb_mc_chats_record` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `uniacid` int(10) unsigned NOT NULL,
  `acid` int(10) unsigned NOT NULL,
  `flag` tinyint(3) unsigned NOT NULL,
  `openid` varchar(32) NOT NULL,
  `msgtype` varchar(15) NOT NULL,
  `content` varchar(10000) NOT NULL,
  `createtime` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `uniacid` (`uniacid`,`acid`),
  KEY `openid` (`openid`),
  KEY `createtime` (`createtime`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_mc_credits_recharge`
--

CREATE TABLE IF NOT EXISTS `wqwdb_mc_credits_recharge` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `uniacid` int(10) unsigned NOT NULL,
  `uid` int(10) unsigned NOT NULL,
  `openid` varchar(50) NOT NULL,
  `tid` varchar(64) NOT NULL,
  `transid` varchar(30) NOT NULL,
  `fee` varchar(10) NOT NULL,
  `type` varchar(15) NOT NULL,
  `tag` varchar(10) NOT NULL,
  `status` tinyint(1) NOT NULL,
  `createtime` int(10) unsigned NOT NULL,
  `backtype` tinyint(3) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_uniacid_uid` (`uniacid`,`uid`),
  KEY `idx_tid` (`tid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_mc_credits_record`
--

CREATE TABLE IF NOT EXISTS `wqwdb_mc_credits_record` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `uid` int(10) unsigned NOT NULL,
  `uniacid` int(11) NOT NULL,
  `credittype` varchar(10) NOT NULL,
  `num` decimal(10,2) NOT NULL,
  `operator` int(10) unsigned NOT NULL,
  `module` varchar(30) NOT NULL,
  `clerk_id` int(10) unsigned NOT NULL,
  `store_id` int(10) unsigned NOT NULL,
  `clerk_type` tinyint(3) unsigned NOT NULL,
  `createtime` int(10) unsigned NOT NULL,
  `remark` varchar(200) NOT NULL,
  `real_uniacid` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `uniacid` (`uniacid`),
  KEY `uid` (`uid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_mc_fans_groups`
--

CREATE TABLE IF NOT EXISTS `wqwdb_mc_fans_groups` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `uniacid` int(10) unsigned NOT NULL,
  `acid` int(10) unsigned NOT NULL,
  `groups` varchar(10000) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `uniacid` (`uniacid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_mc_fans_tag_mapping`
--

CREATE TABLE IF NOT EXISTS `wqwdb_mc_fans_tag_mapping` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `fanid` int(11) unsigned NOT NULL,
  `tagid` varchar(20) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `mapping` (`fanid`,`tagid`),
  KEY `fanid_index` (`fanid`),
  KEY `tagid_index` (`tagid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_mc_groups`
--

CREATE TABLE IF NOT EXISTS `wqwdb_mc_groups` (
  `groupid` int(11) NOT NULL AUTO_INCREMENT,
  `uniacid` int(11) NOT NULL,
  `title` varchar(20) NOT NULL,
  `credit` int(10) unsigned NOT NULL,
  `isdefault` tinyint(4) NOT NULL,
  PRIMARY KEY (`groupid`),
  KEY `uniacid` (`uniacid`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=2 ;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_mc_handsel`
--

CREATE TABLE IF NOT EXISTS `wqwdb_mc_handsel` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `uniacid` int(10) NOT NULL,
  `touid` int(10) unsigned NOT NULL,
  `fromuid` varchar(32) NOT NULL,
  `module` varchar(30) NOT NULL,
  `sign` varchar(100) NOT NULL,
  `action` varchar(20) NOT NULL,
  `credit_value` int(10) unsigned NOT NULL,
  `createtime` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `uid` (`touid`),
  KEY `uniacid` (`uniacid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_mc_mapping_fans`
--

CREATE TABLE IF NOT EXISTS `wqwdb_mc_mapping_fans` (
  `fanid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `acid` int(10) unsigned NOT NULL,
  `uniacid` int(10) unsigned NOT NULL,
  `uid` int(10) unsigned NOT NULL,
  `openid` varchar(50) NOT NULL,
  `nickname` varchar(50) NOT NULL,
  `groupid` varchar(60) NOT NULL,
  `salt` char(8) NOT NULL,
  `follow` tinyint(1) unsigned NOT NULL,
  `followtime` int(10) unsigned NOT NULL,
  `unfollowtime` int(10) unsigned NOT NULL,
  `tag` varchar(1000) NOT NULL,
  `updatetime` int(10) unsigned DEFAULT NULL,
  `unionid` varchar(64) NOT NULL,
  PRIMARY KEY (`fanid`),
  UNIQUE KEY `openid_2` (`openid`),
  KEY `acid` (`acid`),
  KEY `uniacid` (`uniacid`),
  KEY `nickname` (`nickname`),
  KEY `updatetime` (`updatetime`),
  KEY `uid` (`uid`),
  KEY `openid` (`openid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_mc_mapping_ucenter`
--

CREATE TABLE IF NOT EXISTS `wqwdb_mc_mapping_ucenter` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `uniacid` int(10) unsigned NOT NULL,
  `uid` int(10) unsigned NOT NULL,
  `centeruid` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_mc_mass_record`
--

CREATE TABLE IF NOT EXISTS `wqwdb_mc_mass_record` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `uniacid` int(10) unsigned NOT NULL,
  `acid` int(10) unsigned NOT NULL,
  `groupname` varchar(50) NOT NULL,
  `fansnum` int(10) unsigned NOT NULL,
  `msgtype` varchar(10) NOT NULL,
  `content` varchar(10000) NOT NULL,
  `group` int(10) NOT NULL,
  `attach_id` int(10) unsigned NOT NULL,
  `media_id` varchar(100) NOT NULL,
  `type` tinyint(3) unsigned NOT NULL,
  `status` tinyint(3) unsigned NOT NULL,
  `cron_id` int(10) unsigned NOT NULL,
  `sendtime` int(10) unsigned NOT NULL,
  `finalsendtime` int(10) unsigned NOT NULL,
  `createtime` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `uniacid` (`uniacid`,`acid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_mc_members`
--

CREATE TABLE IF NOT EXISTS `wqwdb_mc_members` (
  `uid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `uniacid` int(10) unsigned NOT NULL,
  `mobile` varchar(18) NOT NULL,
  `email` varchar(50) NOT NULL,
  `password` varchar(32) NOT NULL,
  `salt` varchar(8) NOT NULL,
  `groupid` int(11) NOT NULL,
  `credit1` decimal(10,2) unsigned NOT NULL,
  `credit2` decimal(10,2) unsigned NOT NULL,
  `credit3` decimal(10,2) unsigned NOT NULL,
  `credit4` decimal(10,2) unsigned NOT NULL,
  `credit5` decimal(10,2) unsigned NOT NULL,
  `credit6` decimal(10,2) NOT NULL,
  `createtime` int(10) unsigned NOT NULL,
  `realname` varchar(10) NOT NULL,
  `nickname` varchar(20) NOT NULL,
  `avatar` varchar(255) NOT NULL,
  `qq` varchar(15) NOT NULL,
  `vip` tinyint(3) unsigned NOT NULL,
  `gender` tinyint(1) NOT NULL,
  `birthyear` smallint(6) unsigned NOT NULL,
  `birthmonth` tinyint(3) unsigned NOT NULL,
  `birthday` tinyint(3) unsigned NOT NULL,
  `constellation` varchar(10) NOT NULL,
  `zodiac` varchar(5) NOT NULL,
  `telephone` varchar(15) NOT NULL,
  `idcard` varchar(30) NOT NULL,
  `studentid` varchar(50) NOT NULL,
  `grade` varchar(10) NOT NULL,
  `address` varchar(255) NOT NULL,
  `zipcode` varchar(10) NOT NULL,
  `nationality` varchar(30) NOT NULL,
  `resideprovince` varchar(30) NOT NULL,
  `residecity` varchar(30) NOT NULL,
  `residedist` varchar(30) NOT NULL,
  `graduateschool` varchar(50) NOT NULL,
  `company` varchar(50) NOT NULL,
  `education` varchar(10) NOT NULL,
  `occupation` varchar(30) NOT NULL,
  `position` varchar(30) NOT NULL,
  `revenue` varchar(10) NOT NULL,
  `affectivestatus` varchar(30) NOT NULL,
  `lookingfor` varchar(255) NOT NULL,
  `bloodtype` varchar(5) NOT NULL,
  `height` varchar(5) NOT NULL,
  `weight` varchar(5) NOT NULL,
  `alipay` varchar(30) NOT NULL,
  `msn` varchar(30) NOT NULL,
  `taobao` varchar(30) NOT NULL,
  `site` varchar(30) NOT NULL,
  `bio` text NOT NULL,
  `interest` text NOT NULL,
  `pay_password` varchar(30) NOT NULL,
  PRIMARY KEY (`uid`),
  KEY `groupid` (`groupid`),
  KEY `uniacid` (`uniacid`),
  KEY `email` (`email`),
  KEY `mobile` (`mobile`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_mc_member_address`
--

CREATE TABLE IF NOT EXISTS `wqwdb_mc_member_address` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `uniacid` int(10) unsigned NOT NULL,
  `uid` int(50) unsigned NOT NULL,
  `username` varchar(20) NOT NULL,
  `mobile` varchar(11) NOT NULL,
  `zipcode` varchar(6) NOT NULL,
  `province` varchar(32) NOT NULL,
  `city` varchar(32) NOT NULL,
  `district` varchar(32) NOT NULL,
  `address` varchar(512) NOT NULL,
  `isdefault` tinyint(1) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_uinacid` (`uniacid`),
  KEY `idx_uid` (`uid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_mc_member_fields`
--

CREATE TABLE IF NOT EXISTS `wqwdb_mc_member_fields` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `uniacid` int(10) NOT NULL,
  `fieldid` int(10) NOT NULL,
  `title` varchar(255) NOT NULL,
  `available` tinyint(1) NOT NULL,
  `displayorder` smallint(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_uniacid` (`uniacid`),
  KEY `idx_fieldid` (`fieldid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_mc_member_property`
--

CREATE TABLE IF NOT EXISTS `wqwdb_mc_member_property` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `uniacid` int(11) NOT NULL,
  `property` varchar(200) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_mc_oauth_fans`
--

CREATE TABLE IF NOT EXISTS `wqwdb_mc_oauth_fans` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `oauth_openid` varchar(50) NOT NULL,
  `acid` int(10) unsigned NOT NULL,
  `uid` int(10) unsigned NOT NULL,
  `openid` varchar(50) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_oauthopenid_acid` (`oauth_openid`,`acid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_menu_event`
--

CREATE TABLE IF NOT EXISTS `wqwdb_menu_event` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `uniacid` int(10) unsigned NOT NULL,
  `keyword` varchar(30) NOT NULL,
  `type` varchar(30) NOT NULL,
  `picmd5` varchar(32) NOT NULL,
  `openid` varchar(128) NOT NULL,
  `createtime` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `uniacid` (`uniacid`),
  KEY `picmd5` (`picmd5`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_message_notice_log`
--

CREATE TABLE IF NOT EXISTS `wqwdb_message_notice_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `message` varchar(255) NOT NULL,
  `is_read` tinyint(3) NOT NULL,
  `uid` int(11) NOT NULL,
  `sign` varchar(22) NOT NULL,
  `type` tinyint(3) NOT NULL,
  `status` tinyint(3) DEFAULT NULL,
  `create_time` int(11) NOT NULL,
  `end_time` int(11) NOT NULL,
  `url` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_mobilenumber`
--

CREATE TABLE IF NOT EXISTS `wqwdb_mobilenumber` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `rid` int(10) NOT NULL,
  `enabled` tinyint(1) unsigned NOT NULL,
  `dateline` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_modules`
--

CREATE TABLE IF NOT EXISTS `wqwdb_modules` (
  `mid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `type` varchar(20) NOT NULL,
  `title` varchar(100) NOT NULL,
  `version` varchar(15) NOT NULL,
  `ability` varchar(500) NOT NULL,
  `description` varchar(1000) NOT NULL,
  `author` varchar(50) NOT NULL,
  `url` varchar(255) NOT NULL,
  `settings` tinyint(1) NOT NULL,
  `subscribes` varchar(500) NOT NULL,
  `handles` varchar(500) NOT NULL,
  `isrulefields` tinyint(1) NOT NULL,
  `issystem` tinyint(1) unsigned NOT NULL,
  `target` int(10) unsigned NOT NULL,
  `iscard` tinyint(3) unsigned NOT NULL,
  `permissions` varchar(5000) NOT NULL,
  `title_initial` varchar(1) NOT NULL,
  `wxapp_support` tinyint(1) NOT NULL,
  `welcome_support` int(2) NOT NULL,
  `oauth_type` tinyint(1) NOT NULL,
  `webapp_support` tinyint(1) NOT NULL,
  `phoneapp_support` tinyint(1) NOT NULL,
  `account_support` tinyint(1) NOT NULL,
  `xzapp_support` tinyint(1) NOT NULL,
  `app_support` tinyint(1) NOT NULL,
  `aliapp_support` tinyint(1) NOT NULL,
  PRIMARY KEY (`mid`),
  KEY `idx_name` (`name`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=13 ;

--
-- 转存表中的数据 `wqwdb_modules`
--

INSERT INTO `wqwdb_modules` (`mid`, `name`, `type`, `title`, `version`, `ability`, `description`, `author`, `url`, `settings`, `subscribes`, `handles`, `isrulefields`, `issystem`, `target`, `iscard`, `permissions`, `title_initial`, `wxapp_support`, `welcome_support`, `oauth_type`, `webapp_support`, `phoneapp_support`, `account_support`, `xzapp_support`, `app_support`, `aliapp_support`) VALUES
(1, 'basic', 'system', '基本文字回复', '1.0', '和您进行简单对话', '一问一答得简单对话. 当访客的对话语句中包含指定关键字, 或对话语句完全等于特定关键字, 或符合某些特定的格式时. 系统自动应答设定好的回复内容.', 'WeEngine Team', 'http://www.we7.cc/', 0, '', '', 1, 1, 0, 0, '', '', 1, 1, 1, 1, 0, 2, 0, 0, 0),
(2, 'news', 'system', '基本混合图文回复', '1.0', '为你提供生动的图文资讯', '一问一答得简单对话, 但是回复内容包括图片文字等更生动的媒体内容. 当访客的对话语句中包含指定关键字, 或对话语句完全等于特定关键字, 或符合某些特定的格式时. 系统自动应答设定好的图文回复内容.', 'WeEngine Team', 'http://www.we7.cc/', 0, '', '', 1, 1, 0, 0, '', '', 1, 1, 1, 1, 0, 2, 0, 0, 0),
(3, 'music', 'system', '基本音乐回复', '1.0', '提供语音、音乐等音频类回复', '在回复规则中可选择具有语音、音乐等音频类的回复内容，并根据用户所设置的特定关键字精准的返回给粉丝，实现一问一答得简单对话。', 'WeEngine Team', 'http://www.we7.cc/', 0, '', '', 1, 1, 0, 0, '', '', 1, 1, 1, 1, 0, 2, 0, 0, 0),
(4, 'userapi', 'system', '自定义接口回复', '1.1', '更方便的第三方接口设置', '自定义接口又称第三方接口，可以让开发者更方便的接入微擎系统，高效的与微信公众平台进行对接整合。', 'WeEngine Team', 'http://www.we7.cc/', 0, '', '', 1, 1, 0, 0, '', '', 1, 1, 1, 1, 0, 2, 0, 0, 0),
(5, 'recharge', 'system', '会员中心充值模块', '1.0', '提供会员充值功能', '', 'WeEngine Team', 'http://www.we7.cc/', 0, '', '', 0, 1, 0, 0, '', '', 1, 1, 1, 1, 0, 2, 0, 0, 0),
(6, 'custom', 'system', '多客服转接', '1.0.0', '用来接入腾讯的多客服系统', '', 'WeEngine Team', 'http://bbs.we7.cc', 0, 'a:0:{}', 'a:6:{i:0;s:5:"image";i:1;s:5:"voice";i:2;s:5:"video";i:3;s:8:"location";i:4;s:4:"link";i:5;s:4:"text";}', 1, 1, 0, 0, '', '', 1, 1, 1, 1, 0, 2, 0, 0, 0),
(7, 'images', 'system', '基本图片回复', '1.0', '提供图片回复', '在回复规则中可选择具有图片的回复内容，并根据用户所设置的特定关键字精准的返回给粉丝图片。', 'WeEngine Team', 'http://www.we7.cc/', 0, '', '', 1, 1, 0, 0, '', '', 1, 1, 1, 1, 0, 2, 0, 0, 0),
(8, 'video', 'system', '基本视频回复', '1.0', '提供图片回复', '在回复规则中可选择具有视频的回复内容，并根据用户所设置的特定关键字精准的返回给粉丝视频。', 'WeEngine Team', 'http://www.we7.cc/', 0, '', '', 1, 1, 0, 0, '', '', 1, 1, 1, 1, 0, 2, 0, 0, 0),
(9, 'voice', 'system', '基本语音回复', '1.0', '提供语音回复', '在回复规则中可选择具有语音的回复内容，并根据用户所设置的特定关键字精准的返回给粉丝语音。', 'WeEngine Team', 'http://www.we7.cc/', 0, '', '', 1, 1, 0, 0, '', '', 1, 1, 1, 1, 0, 2, 0, 0, 0),
(10, 'chats', 'system', '发送客服消息', '1.0', '公众号可以在粉丝最后发送消息的48小时内无限制发送消息', '', 'WeEngine Team', 'http://www.we7.cc/', 0, '', '', 0, 1, 0, 0, '', '', 1, 1, 1, 1, 0, 2, 0, 0, 0),
(11, 'wxcard', 'system', '微信卡券回复', '1.0', '微信卡券回复', '微信卡券回复', 'WeEngine Team', 'http://www.we7.cc/', 0, '', '', 1, 1, 0, 0, '', '', 1, 1, 1, 1, 0, 2, 0, 0, 0),
(12, 'store', 'business', '站内商城', '1.0', '站内商城', '站内商城', 'WeEngine Team', 'http://www.we7.cc/', 0, '', '', 0, 1, 0, 0, '', '', 1, 1, 1, 1, 0, 2, 0, 0, 0);

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_modules_bindings`
--

CREATE TABLE IF NOT EXISTS `wqwdb_modules_bindings` (
  `eid` int(11) NOT NULL AUTO_INCREMENT,
  `module` varchar(100) NOT NULL,
  `entry` varchar(30) NOT NULL,
  `call` varchar(50) NOT NULL,
  `title` varchar(50) NOT NULL,
  `do` varchar(200) NOT NULL,
  `state` varchar(200) NOT NULL,
  `direct` int(11) NOT NULL,
  `url` varchar(100) NOT NULL,
  `icon` varchar(50) NOT NULL,
  `displayorder` tinyint(255) unsigned NOT NULL,
  PRIMARY KEY (`eid`),
  KEY `idx_module` (`module`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_modules_cloud`
--

CREATE TABLE IF NOT EXISTS `wqwdb_modules_cloud` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `title` varchar(100) NOT NULL,
  `title_initial` varchar(1) NOT NULL,
  `logo` varchar(100) NOT NULL,
  `version` varchar(10) NOT NULL,
  `install_status` tinyint(4) NOT NULL,
  `account_support` tinyint(4) NOT NULL,
  `wxapp_support` tinyint(4) NOT NULL,
  `webapp_support` tinyint(4) NOT NULL,
  `phoneapp_support` tinyint(4) NOT NULL,
  `welcome_support` tinyint(4) NOT NULL,
  `main_module_name` varchar(50) NOT NULL,
  `main_module_logo` varchar(100) NOT NULL,
  `has_new_version` tinyint(1) NOT NULL,
  `has_new_branch` tinyint(1) NOT NULL,
  `is_ban` tinyint(4) NOT NULL,
  `lastupdatetime` int(11) NOT NULL,
  `xzapp_support` tinyint(1) NOT NULL,
  `cloud_id` int(11) NOT NULL,
  `aliapp_support` tinyint(1) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `name` (`name`),
  KEY `lastupdatetime` (`lastupdatetime`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_modules_ignore`
--

CREATE TABLE IF NOT EXISTS `wqwdb_modules_ignore` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `version` varchar(15) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `name` (`name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_modules_plugin`
--

CREATE TABLE IF NOT EXISTS `wqwdb_modules_plugin` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) DEFAULT NULL,
  `main_module` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `name` (`name`),
  KEY `main_module` (`main_module`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_modules_rank`
--

CREATE TABLE IF NOT EXISTS `wqwdb_modules_rank` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `module_name` varchar(100) NOT NULL,
  `uid` int(10) NOT NULL,
  `rank` int(10) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `module_name` (`module_name`),
  KEY `uid` (`uid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_modules_recycle`
--

CREATE TABLE IF NOT EXISTS `wqwdb_modules_recycle` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `type` tinyint(4) NOT NULL,
  `modulename` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `name` (`name`),
  KEY `modulename` (`modulename`) USING BTREE
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_music_reply`
--

CREATE TABLE IF NOT EXISTS `wqwdb_music_reply` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `rid` int(10) unsigned NOT NULL,
  `title` varchar(50) NOT NULL,
  `description` varchar(255) NOT NULL,
  `url` varchar(300) NOT NULL,
  `hqurl` varchar(300) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `rid` (`rid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_news_reply`
--

CREATE TABLE IF NOT EXISTS `wqwdb_news_reply` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `rid` int(10) unsigned NOT NULL,
  `parent_id` int(10) NOT NULL,
  `title` varchar(50) NOT NULL,
  `author` varchar(64) NOT NULL,
  `description` varchar(255) NOT NULL,
  `thumb` varchar(500) NOT NULL,
  `content` mediumtext NOT NULL,
  `url` varchar(255) NOT NULL,
  `displayorder` int(10) NOT NULL,
  `incontent` tinyint(1) NOT NULL,
  `createtime` int(10) NOT NULL,
  `media_id` varchar(50) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `rid` (`rid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_phoneapp_versions`
--

CREATE TABLE IF NOT EXISTS `wqwdb_phoneapp_versions` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `uniacid` int(10) NOT NULL,
  `version` varchar(20) DEFAULT NULL,
  `description` varchar(255) NOT NULL,
  `modules` text,
  `createtime` int(10) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `version` (`version`),
  KEY `uniacid` (`uniacid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_profile_fields`
--

CREATE TABLE IF NOT EXISTS `wqwdb_profile_fields` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `field` varchar(255) NOT NULL,
  `available` tinyint(1) NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` varchar(255) NOT NULL,
  `displayorder` smallint(6) NOT NULL,
  `required` tinyint(1) NOT NULL,
  `unchangeable` tinyint(1) NOT NULL,
  `showinregister` tinyint(1) NOT NULL,
  `field_length` int(10) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=37 ;

--
-- 转存表中的数据 `wqwdb_profile_fields`
--

INSERT INTO `wqwdb_profile_fields` (`id`, `field`, `available`, `title`, `description`, `displayorder`, `required`, `unchangeable`, `showinregister`, `field_length`) VALUES
(1, 'realname', 1, '真实姓名', '', 0, 1, 1, 1, 0),
(2, 'nickname', 1, '昵称', '', 1, 1, 0, 1, 0),
(3, 'avatar', 1, '头像', '', 1, 0, 0, 0, 0),
(4, 'qq', 1, 'QQ号', '', 0, 0, 0, 1, 0),
(5, 'mobile', 1, '手机号码', '', 0, 0, 0, 0, 0),
(6, 'vip', 1, 'VIP级别', '', 0, 0, 0, 0, 0),
(7, 'gender', 1, '性别', '', 0, 0, 0, 0, 0),
(8, 'birthyear', 1, '出生生日', '', 0, 0, 0, 0, 0),
(9, 'constellation', 1, '星座', '', 0, 0, 0, 0, 0),
(10, 'zodiac', 1, '生肖', '', 0, 0, 0, 0, 0),
(11, 'telephone', 1, '固定电话', '', 0, 0, 0, 0, 0),
(12, 'idcard', 1, '证件号码', '', 0, 0, 0, 0, 0),
(13, 'studentid', 1, '学号', '', 0, 0, 0, 0, 0),
(14, 'grade', 1, '班级', '', 0, 0, 0, 0, 0),
(15, 'address', 1, '邮寄地址', '', 0, 0, 0, 0, 0),
(16, 'zipcode', 1, '邮编', '', 0, 0, 0, 0, 0),
(17, 'nationality', 1, '国籍', '', 0, 0, 0, 0, 0),
(18, 'resideprovince', 1, '居住地址', '', 0, 0, 0, 0, 0),
(19, 'graduateschool', 1, '毕业学校', '', 0, 0, 0, 0, 0),
(20, 'company', 1, '公司', '', 0, 0, 0, 0, 0),
(21, 'education', 1, '学历', '', 0, 0, 0, 0, 0),
(22, 'occupation', 1, '职业', '', 0, 0, 0, 0, 0),
(23, 'position', 1, '职位', '', 0, 0, 0, 0, 0),
(24, 'revenue', 1, '年收入', '', 0, 0, 0, 0, 0),
(25, 'affectivestatus', 1, '情感状态', '', 0, 0, 0, 0, 0),
(26, 'lookingfor', 1, ' 交友目的', '', 0, 0, 0, 0, 0),
(27, 'bloodtype', 1, '血型', '', 0, 0, 0, 0, 0),
(28, 'height', 1, '身高', '', 0, 0, 0, 0, 0),
(29, 'weight', 1, '体重', '', 0, 0, 0, 0, 0),
(30, 'alipay', 1, '支付宝帐号', '', 0, 0, 0, 0, 0),
(31, 'msn', 1, 'MSN', '', 0, 0, 0, 0, 0),
(32, 'email', 1, '电子邮箱', '', 0, 0, 0, 0, 0),
(33, 'taobao', 1, '阿里旺旺', '', 0, 0, 0, 0, 0),
(34, 'site', 1, '主页', '', 0, 0, 0, 0, 0),
(35, 'bio', 1, '自我介绍', '', 0, 0, 0, 0, 0),
(36, 'interest', 1, '兴趣爱好', '', 0, 0, 0, 0, 0);

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_qrcode`
--

CREATE TABLE IF NOT EXISTS `wqwdb_qrcode` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `uniacid` int(10) unsigned NOT NULL,
  `acid` int(10) unsigned NOT NULL,
  `type` varchar(10) NOT NULL,
  `extra` int(10) unsigned NOT NULL,
  `qrcid` bigint(20) NOT NULL,
  `scene_str` varchar(64) NOT NULL,
  `name` varchar(50) NOT NULL,
  `keyword` varchar(100) NOT NULL,
  `model` tinyint(1) unsigned NOT NULL,
  `ticket` varchar(250) NOT NULL,
  `url` varchar(256) NOT NULL,
  `expire` int(10) unsigned NOT NULL,
  `subnum` int(10) unsigned NOT NULL,
  `createtime` int(10) unsigned NOT NULL,
  `status` tinyint(1) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_qrcid` (`qrcid`),
  KEY `uniacid` (`uniacid`),
  KEY `ticket` (`ticket`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_qrcode_stat`
--

CREATE TABLE IF NOT EXISTS `wqwdb_qrcode_stat` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `uniacid` int(10) unsigned NOT NULL,
  `acid` int(10) unsigned NOT NULL,
  `qid` int(10) unsigned NOT NULL,
  `openid` varchar(50) NOT NULL,
  `type` tinyint(1) unsigned NOT NULL,
  `qrcid` bigint(20) unsigned NOT NULL,
  `scene_str` varchar(64) NOT NULL,
  `name` varchar(50) NOT NULL,
  `createtime` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_rule`
--

CREATE TABLE IF NOT EXISTS `wqwdb_rule` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `uniacid` int(10) unsigned NOT NULL,
  `name` varchar(50) NOT NULL,
  `module` varchar(50) NOT NULL,
  `displayorder` int(10) unsigned NOT NULL,
  `status` tinyint(1) unsigned NOT NULL,
  `containtype` varchar(100) NOT NULL,
  `reply_type` tinyint(1) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=9 ;

--
-- 转存表中的数据 `wqwdb_rule`
--

INSERT INTO `wqwdb_rule` (`id`, `uniacid`, `name`, `module`, `displayorder`, `status`, `containtype`, `reply_type`) VALUES
(1, 0, '城市天气', 'userapi', 255, 1, '', 0),
(2, 0, '百度百科', 'userapi', 255, 1, '', 0),
(3, 0, '即时翻译', 'userapi', 255, 1, '', 0),
(4, 0, '今日老黄历', 'userapi', 255, 1, '', 0),
(5, 0, '看新闻', 'userapi', 255, 1, '', 0),
(6, 0, '快递查询', 'userapi', 255, 1, '', 0);

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_rule_keyword`
--

CREATE TABLE IF NOT EXISTS `wqwdb_rule_keyword` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `rid` int(10) unsigned NOT NULL,
  `uniacid` int(10) unsigned NOT NULL,
  `module` varchar(50) NOT NULL,
  `content` varchar(255) NOT NULL,
  `type` tinyint(1) unsigned NOT NULL,
  `displayorder` tinyint(3) unsigned NOT NULL,
  `status` tinyint(1) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_content` (`content`),
  KEY `rid` (`rid`),
  KEY `idx_rid` (`rid`),
  KEY `idx_uniacid_type_content` (`uniacid`,`type`,`content`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=13 ;

--
-- 转存表中的数据 `wqwdb_rule_keyword`
--

INSERT INTO `wqwdb_rule_keyword` (`id`, `rid`, `uniacid`, `module`, `content`, `type`, `displayorder`, `status`) VALUES
(1, 1, 0, 'userapi', '^.+天气$', 3, 255, 1),
(2, 2, 0, 'userapi', '^百科.+$', 3, 255, 1),
(3, 2, 0, 'userapi', '^定义.+$', 3, 255, 1),
(4, 3, 0, 'userapi', '^@.+$', 3, 255, 1),
(5, 4, 0, 'userapi', '日历', 1, 255, 1),
(6, 4, 0, 'userapi', '万年历', 1, 255, 1),
(7, 4, 0, 'userapi', '黄历', 1, 255, 1),
(8, 4, 0, 'userapi', '几号', 1, 255, 1),
(9, 5, 0, 'userapi', '新闻', 1, 255, 1),
(10, 6, 0, 'userapi', '^(申通|圆通|中通|汇通|韵达|顺丰|EMS) *[a-z0-9]{1,}$', 3, 255, 1);

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_site_article`
--

CREATE TABLE IF NOT EXISTS `wqwdb_site_article` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `uniacid` int(10) unsigned NOT NULL,
  `rid` int(10) unsigned NOT NULL,
  `kid` int(10) unsigned NOT NULL,
  `iscommend` tinyint(1) NOT NULL,
  `ishot` tinyint(1) unsigned NOT NULL,
  `pcate` int(10) unsigned NOT NULL,
  `ccate` int(10) unsigned NOT NULL,
  `template` varchar(300) NOT NULL,
  `title` varchar(100) NOT NULL,
  `description` varchar(100) NOT NULL,
  `content` mediumtext NOT NULL,
  `thumb` varchar(255) NOT NULL,
  `incontent` tinyint(1) NOT NULL,
  `source` varchar(255) NOT NULL,
  `author` varchar(50) NOT NULL,
  `displayorder` int(10) unsigned NOT NULL,
  `linkurl` varchar(500) NOT NULL,
  `createtime` int(10) unsigned NOT NULL,
  `edittime` int(10) NOT NULL,
  `click` int(10) unsigned NOT NULL,
  `type` varchar(10) NOT NULL,
  `credit` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_iscommend` (`iscommend`),
  KEY `idx_ishot` (`ishot`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_site_article_comment`
--

CREATE TABLE IF NOT EXISTS `wqwdb_site_article_comment` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `uniacid` int(10) NOT NULL,
  `articleid` int(10) NOT NULL,
  `parentid` int(10) NOT NULL,
  `uid` int(10) NOT NULL,
  `openid` varchar(50) NOT NULL,
  `content` text,
  `is_read` tinyint(1) NOT NULL,
  `iscomment` tinyint(1) NOT NULL,
  `createtime` int(10) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `uniacid` (`uniacid`),
  KEY `articleid` (`articleid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_site_category`
--

CREATE TABLE IF NOT EXISTS `wqwdb_site_category` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `uniacid` int(10) unsigned NOT NULL,
  `nid` int(10) unsigned NOT NULL,
  `name` varchar(50) NOT NULL,
  `parentid` int(10) unsigned NOT NULL,
  `displayorder` tinyint(3) unsigned NOT NULL,
  `enabled` tinyint(1) unsigned NOT NULL,
  `icon` varchar(100) NOT NULL,
  `description` varchar(100) NOT NULL,
  `styleid` int(10) unsigned NOT NULL,
  `linkurl` varchar(500) NOT NULL,
  `ishomepage` tinyint(1) NOT NULL,
  `icontype` tinyint(1) unsigned NOT NULL,
  `css` varchar(500) NOT NULL,
  `multiid` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_site_multi`
--

CREATE TABLE IF NOT EXISTS `wqwdb_site_multi` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `uniacid` int(10) unsigned NOT NULL,
  `title` varchar(30) NOT NULL,
  `styleid` int(10) unsigned NOT NULL,
  `site_info` text NOT NULL,
  `status` tinyint(3) unsigned NOT NULL,
  `bindhost` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `uniacid` (`uniacid`),
  KEY `bindhost` (`bindhost`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=2 ;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_site_nav`
--

CREATE TABLE IF NOT EXISTS `wqwdb_site_nav` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `uniacid` int(10) unsigned NOT NULL,
  `multiid` int(10) unsigned NOT NULL,
  `section` tinyint(4) NOT NULL,
  `module` varchar(50) NOT NULL,
  `displayorder` smallint(5) unsigned NOT NULL,
  `name` varchar(50) NOT NULL,
  `description` varchar(1000) NOT NULL,
  `position` tinyint(4) NOT NULL,
  `url` varchar(255) NOT NULL,
  `icon` varchar(500) NOT NULL,
  `css` varchar(1000) NOT NULL,
  `status` tinyint(1) unsigned NOT NULL,
  `categoryid` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `uniacid` (`uniacid`),
  KEY `multiid` (`multiid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_site_page`
--

CREATE TABLE IF NOT EXISTS `wqwdb_site_page` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `uniacid` int(10) unsigned NOT NULL,
  `multiid` int(10) unsigned NOT NULL,
  `title` varchar(50) NOT NULL,
  `description` varchar(255) NOT NULL,
  `params` longtext NOT NULL,
  `html` longtext NOT NULL,
  `multipage` longtext NOT NULL,
  `type` tinyint(1) unsigned NOT NULL,
  `status` tinyint(1) unsigned NOT NULL,
  `createtime` int(10) unsigned NOT NULL,
  `goodnum` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `uniacid` (`uniacid`),
  KEY `multiid` (`multiid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_site_slide`
--

CREATE TABLE IF NOT EXISTS `wqwdb_site_slide` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `uniacid` int(10) unsigned NOT NULL,
  `multiid` int(10) unsigned NOT NULL,
  `title` varchar(255) NOT NULL,
  `url` varchar(255) NOT NULL,
  `thumb` varchar(255) NOT NULL,
  `displayorder` tinyint(4) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `uniacid` (`uniacid`),
  KEY `multiid` (`multiid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_site_store_create_account`
--

CREATE TABLE IF NOT EXISTS `wqwdb_site_store_create_account` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `uid` int(10) NOT NULL,
  `uniacid` int(10) NOT NULL,
  `type` tinyint(4) NOT NULL,
  `endtime` int(12) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_site_store_goods`
--

CREATE TABLE IF NOT EXISTS `wqwdb_site_store_goods` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `type` tinyint(1) NOT NULL,
  `title` varchar(100) NOT NULL,
  `module` varchar(50) NOT NULL,
  `account_num` int(10) NOT NULL,
  `wxapp_num` int(10) NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `unit` varchar(15) NOT NULL,
  `slide` varchar(1000) NOT NULL,
  `category_id` int(10) NOT NULL,
  `title_initial` varchar(1) NOT NULL,
  `status` tinyint(1) NOT NULL,
  `createtime` int(10) NOT NULL,
  `synopsis` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `module_group` int(10) NOT NULL,
  `api_num` int(10) NOT NULL,
  `user_group` int(10) NOT NULL,
  `user_group_price` varchar(1000) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `module` (`module`),
  KEY `category_id` (`category_id`),
  KEY `price` (`price`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_site_store_order`
--

CREATE TABLE IF NOT EXISTS `wqwdb_site_store_order` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `orderid` varchar(28) NOT NULL,
  `goodsid` int(10) NOT NULL,
  `duration` int(10) NOT NULL,
  `buyer` varchar(50) NOT NULL,
  `buyerid` int(10) NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `type` tinyint(1) NOT NULL,
  `changeprice` tinyint(1) NOT NULL,
  `createtime` int(10) NOT NULL,
  `uniacid` int(10) NOT NULL,
  `endtime` int(15) NOT NULL,
  `wxapp` int(15) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `goodid` (`goodsid`),
  KEY `buyerid` (`buyerid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_site_styles`
--

CREATE TABLE IF NOT EXISTS `wqwdb_site_styles` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `uniacid` int(10) unsigned NOT NULL,
  `templateid` int(10) unsigned NOT NULL,
  `name` varchar(50) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=2 ;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_site_styles_vars`
--

CREATE TABLE IF NOT EXISTS `wqwdb_site_styles_vars` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `uniacid` int(10) unsigned NOT NULL,
  `templateid` int(10) unsigned NOT NULL,
  `styleid` int(10) unsigned NOT NULL,
  `variable` varchar(50) NOT NULL,
  `content` text NOT NULL,
  `description` varchar(50) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_site_templates`
--

CREATE TABLE IF NOT EXISTS `wqwdb_site_templates` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(30) NOT NULL,
  `title` varchar(30) NOT NULL,
  `version` varchar(64) NOT NULL,
  `description` varchar(500) NOT NULL,
  `author` varchar(50) NOT NULL,
  `url` varchar(255) NOT NULL,
  `type` varchar(20) NOT NULL,
  `sections` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=2 ;

--
-- 转存表中的数据 `wqwdb_site_templates`
--

INSERT INTO `wqwdb_site_templates` (`id`, `name`, `title`, `version`, `description`, `author`, `url`, `type`, `sections`) VALUES
(1, 'default', '微站默认模板', '', '由微擎提供默认微站模板套系', '微擎团队', 'http://we7.cc', '1', 0);

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_stat_fans`
--

CREATE TABLE IF NOT EXISTS `wqwdb_stat_fans` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `uniacid` int(10) unsigned NOT NULL,
  `new` int(10) unsigned NOT NULL,
  `cancel` int(10) unsigned NOT NULL,
  `cumulate` int(10) NOT NULL,
  `date` varchar(8) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `uniacid` (`uniacid`,`date`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=15 ;

--
-- 转存表中的数据 `wqwdb_stat_fans`
--

INSERT INTO `wqwdb_stat_fans` (`id`, `uniacid`, `new`, `cancel`, `cumulate`, `date`) VALUES
(1, 0, 0, 0, 0, '20190819'),
(2, 0, 0, 0, 0, '20190818'),
(3, 0, 0, 0, 0, '20190817'),
(4, 0, 0, 0, 0, '20190816'),
(5, 0, 0, 0, 0, '20190815'),
(6, 0, 0, 0, 0, '20190814'),
(7, 0, 0, 0, 0, '20190813'),
(8, 1, 0, 0, 0, '20190819'),
(9, 1, 0, 0, 0, '20190818'),
(10, 1, 0, 0, 0, '20190817'),
(11, 1, 0, 0, 0, '20190816'),
(12, 1, 0, 0, 0, '20190815'),
(13, 1, 0, 0, 0, '20190814'),
(14, 1, 0, 0, 0, '20190813');

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_stat_keyword`
--

CREATE TABLE IF NOT EXISTS `wqwdb_stat_keyword` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `uniacid` int(10) unsigned NOT NULL,
  `rid` varchar(10) NOT NULL,
  `kid` int(10) unsigned NOT NULL,
  `hit` int(10) unsigned NOT NULL,
  `lastupdate` int(10) unsigned NOT NULL,
  `createtime` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_createtime` (`createtime`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_stat_msg_history`
--

CREATE TABLE IF NOT EXISTS `wqwdb_stat_msg_history` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `uniacid` int(10) unsigned NOT NULL,
  `rid` int(10) unsigned NOT NULL,
  `kid` int(10) unsigned NOT NULL,
  `from_user` varchar(50) NOT NULL,
  `module` varchar(50) NOT NULL,
  `message` varchar(1000) NOT NULL,
  `type` varchar(10) NOT NULL,
  `createtime` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_createtime` (`createtime`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_stat_rule`
--

CREATE TABLE IF NOT EXISTS `wqwdb_stat_rule` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `uniacid` int(10) unsigned NOT NULL,
  `rid` int(10) unsigned NOT NULL,
  `hit` int(10) unsigned NOT NULL,
  `lastupdate` int(10) unsigned NOT NULL,
  `createtime` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_createtime` (`createtime`),
  KEY `rid` (`rid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_stat_visit`
--

CREATE TABLE IF NOT EXISTS `wqwdb_stat_visit` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `uniacid` int(10) NOT NULL,
  `module` varchar(100) NOT NULL,
  `count` int(10) unsigned NOT NULL,
  `date` int(10) unsigned NOT NULL,
  `type` varchar(10) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `date` (`date`),
  KEY `module` (`module`),
  KEY `uniacid` (`uniacid`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=5 ;

--
-- 转存表中的数据 `wqwdb_stat_visit`
--

INSERT INTO `wqwdb_stat_visit` (`id`, `uniacid`, `module`, `count`, `date`, `type`) VALUES
(2, 0, '', 221, 20190820, 'web'),
(3, 0, 'we7_account', 7, 20190820, 'web'),
(4, 1, 'we7_account', 2, 20190820, 'web');

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_system_stat_visit`
--

CREATE TABLE IF NOT EXISTS `wqwdb_system_stat_visit` (
  `id` int(10) NOT NULL AUTO_INCREMENT,
  `uniacid` int(10) NOT NULL,
  `modulename` varchar(100) NOT NULL,
  `uid` int(10) NOT NULL,
  `displayorder` int(10) NOT NULL,
  `createtime` int(10) NOT NULL,
  `updatetime` int(10) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `uniacid` (`uniacid`),
  KEY `uid` (`uid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_uni_account`
--

CREATE TABLE IF NOT EXISTS `wqwdb_uni_account` (
  `uniacid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `groupid` int(10) NOT NULL,
  `name` varchar(100) NOT NULL,
  `description` varchar(255) NOT NULL,
  `default_acid` int(10) unsigned NOT NULL,
  `rank` int(10) DEFAULT NULL,
  `title_initial` varchar(1) NOT NULL,
  PRIMARY KEY (`uniacid`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=2 ;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_uni_account_group`
--

CREATE TABLE IF NOT EXISTS `wqwdb_uni_account_group` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `uniacid` int(10) unsigned NOT NULL,
  `groupid` int(10) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_uni_account_menus`
--

CREATE TABLE IF NOT EXISTS `wqwdb_uni_account_menus` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `uniacid` int(10) unsigned NOT NULL,
  `menuid` int(10) unsigned NOT NULL,
  `type` tinyint(3) unsigned NOT NULL,
  `title` varchar(30) NOT NULL,
  `sex` tinyint(3) unsigned NOT NULL,
  `group_id` int(10) NOT NULL,
  `client_platform_type` tinyint(3) unsigned NOT NULL,
  `area` varchar(50) NOT NULL,
  `data` text NOT NULL,
  `status` tinyint(3) unsigned NOT NULL,
  `createtime` int(10) unsigned NOT NULL,
  `isdeleted` tinyint(3) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `uniacid` (`uniacid`),
  KEY `menuid` (`menuid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_uni_account_modules`
--

CREATE TABLE IF NOT EXISTS `wqwdb_uni_account_modules` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `uniacid` int(10) unsigned NOT NULL,
  `module` varchar(50) NOT NULL,
  `enabled` tinyint(1) unsigned NOT NULL,
  `settings` text NOT NULL,
  `shortcut` tinyint(1) unsigned NOT NULL,
  `displayorder` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_module` (`module`),
  KEY `idx_uniacid` (`uniacid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_uni_account_users`
--

CREATE TABLE IF NOT EXISTS `wqwdb_uni_account_users` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `uniacid` int(10) unsigned NOT NULL,
  `uid` int(10) unsigned NOT NULL,
  `role` varchar(255) NOT NULL,
  `rank` tinyint(3) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_memberid` (`uid`),
  KEY `uniacid` (`uniacid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_uni_group`
--

CREATE TABLE IF NOT EXISTS `wqwdb_uni_group` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `owner_uid` int(10) NOT NULL,
  `name` varchar(50) NOT NULL,
  `modules` text NOT NULL,
  `templates` varchar(5000) NOT NULL,
  `uniacid` int(10) unsigned NOT NULL,
  `uid` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `uniacid` (`uniacid`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=2 ;

--
-- 转存表中的数据 `wqwdb_uni_group`
--

INSERT INTO `wqwdb_uni_group` (`id`, `owner_uid`, `name`, `modules`, `templates`, `uniacid`, `uid`) VALUES
(1, 0, '体验套餐服务', 'N;', 'N;', 0, 0);

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_uni_settings`
--

CREATE TABLE IF NOT EXISTS `wqwdb_uni_settings` (
  `uniacid` int(10) unsigned NOT NULL,
  `passport` varchar(200) NOT NULL,
  `oauth` varchar(100) NOT NULL,
  `jsauth_acid` int(10) unsigned NOT NULL,
  `uc` varchar(500) NOT NULL,
  `notify` varchar(2000) NOT NULL,
  `creditnames` varchar(500) NOT NULL,
  `creditbehaviors` varchar(500) NOT NULL,
  `welcome` varchar(60) NOT NULL,
  `default` varchar(60) NOT NULL,
  `default_message` varchar(2000) NOT NULL,
  `payment` text NOT NULL,
  `stat` varchar(300) NOT NULL,
  `default_site` int(10) unsigned DEFAULT NULL,
  `sync` tinyint(3) unsigned NOT NULL,
  `recharge` varchar(500) NOT NULL,
  `tplnotice` varchar(1000) NOT NULL,
  `grouplevel` tinyint(3) unsigned NOT NULL,
  `mcplugin` varchar(500) NOT NULL,
  `exchange_enable` tinyint(3) unsigned NOT NULL,
  `coupon_type` tinyint(3) unsigned NOT NULL,
  `menuset` text NOT NULL,
  `statistics` varchar(100) NOT NULL,
  `bind_domain` varchar(200) NOT NULL,
  `comment_status` tinyint(1) NOT NULL,
  `reply_setting` tinyint(4) NOT NULL,
  `default_module` varchar(100) NOT NULL,
  `attachment_limit` int(11) DEFAULT NULL,
  `attachment_size` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`uniacid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_uni_verifycode`
--

CREATE TABLE IF NOT EXISTS `wqwdb_uni_verifycode` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `uniacid` int(10) unsigned NOT NULL,
  `receiver` varchar(50) NOT NULL,
  `verifycode` varchar(6) NOT NULL,
  `total` tinyint(3) unsigned NOT NULL,
  `createtime` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_userapi_cache`
--

CREATE TABLE IF NOT EXISTS `wqwdb_userapi_cache` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `key` varchar(32) NOT NULL,
  `content` text NOT NULL,
  `lastupdate` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_userapi_reply`
--

CREATE TABLE IF NOT EXISTS `wqwdb_userapi_reply` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `rid` int(10) unsigned NOT NULL,
  `description` varchar(300) NOT NULL,
  `apiurl` varchar(300) NOT NULL,
  `token` varchar(32) NOT NULL,
  `default_text` varchar(100) NOT NULL,
  `cachetime` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `rid` (`rid`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=7 ;

--
-- 转存表中的数据 `wqwdb_userapi_reply`
--

INSERT INTO `wqwdb_userapi_reply` (`id`, `rid`, `description`, `apiurl`, `token`, `default_text`, `cachetime`) VALUES
(1, 1, '"城市名+天气", 如: "北京天气"', 'weather.php', '', '', 0),
(2, 2, '"百科+查询内容" 或 "定义+查询内容", 如: "百科姚明", "定义自行车"', 'baike.php', '', '', 0),
(3, 3, '"@查询内容(中文或英文)"', 'translate.php', '', '', 0),
(4, 4, '"日历", "万年历", "黄历"或"几号"', 'calendar.php', '', '', 0),
(5, 5, '"新闻"', 'news.php', '', '', 0),
(6, 6, '"快递+单号", 如: "申通1200041125"', 'express.php', '', '', 0);

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_users`
--

CREATE TABLE IF NOT EXISTS `wqwdb_users` (
  `uid` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `owner_uid` int(10) NOT NULL,
  `groupid` int(10) unsigned NOT NULL,
  `founder_groupid` tinyint(4) NOT NULL,
  `username` varchar(30) NOT NULL,
  `password` varchar(200) NOT NULL,
  `salt` varchar(10) NOT NULL,
  `type` tinyint(3) unsigned NOT NULL,
  `status` tinyint(4) NOT NULL,
  `joindate` int(10) unsigned NOT NULL,
  `joinip` varchar(15) NOT NULL,
  `lastvisit` int(10) unsigned NOT NULL,
  `lastip` varchar(15) NOT NULL,
  `remark` varchar(500) NOT NULL,
  `starttime` int(10) unsigned NOT NULL,
  `endtime` int(10) unsigned NOT NULL,
  `register_type` tinyint(3) NOT NULL,
  `openid` varchar(50) NOT NULL,
  `welcome_link` tinyint(4) NOT NULL,
  `is_bind` tinyint(1) NOT NULL,
  PRIMARY KEY (`uid`),
  UNIQUE KEY `username` (`username`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=2 ;

--
-- 转存表中的数据 `wqwdb_users`
--

INSERT INTO `wqwdb_users` (`uid`, `owner_uid`, `groupid`, `founder_groupid`, `username`, `password`, `salt`, `type`, `status`, `joindate`, `joinip`, `lastvisit`, `lastip`, `remark`, `starttime`, `endtime`, `register_type`, `openid`, `welcome_link`, `is_bind`) VALUES
(1, 0, 1, 0, 'zesso', '5d6baefe3b9331f40a5b0f298f1c390da8577c1c', 'd4370817', 0, 0, 1566281453, '', 1566287821, '127.0.0.1', '', 0, 0, 0, '', 0, 0);

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_users_bind`
--

CREATE TABLE IF NOT EXISTS `wqwdb_users_bind` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `uid` int(11) NOT NULL,
  `bind_sign` varchar(50) NOT NULL,
  `third_type` tinyint(4) NOT NULL,
  `third_nickname` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `uid` (`uid`),
  KEY `bind_sign` (`bind_sign`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_users_failed_login`
--

CREATE TABLE IF NOT EXISTS `wqwdb_users_failed_login` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `ip` varchar(15) NOT NULL,
  `username` varchar(32) NOT NULL,
  `count` tinyint(1) unsigned NOT NULL,
  `lastupdate` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `ip_username` (`ip`,`username`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_users_founder_group`
--

CREATE TABLE IF NOT EXISTS `wqwdb_users_founder_group` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `package` varchar(5000) NOT NULL,
  `maxaccount` int(10) unsigned NOT NULL,
  `maxsubaccount` int(10) unsigned NOT NULL,
  `timelimit` int(10) unsigned NOT NULL,
  `maxwxapp` int(10) unsigned NOT NULL,
  `maxwebapp` int(10) NOT NULL,
  `maxphoneapp` int(10) NOT NULL,
  `maxxzapp` int(10) NOT NULL,
  `maxaliapp` int(10) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_users_group`
--

CREATE TABLE IF NOT EXISTS `wqwdb_users_group` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `owner_uid` int(10) NOT NULL,
  `name` varchar(50) NOT NULL,
  `package` varchar(5000) NOT NULL,
  `maxaccount` int(10) unsigned NOT NULL,
  `maxsubaccount` int(10) unsigned NOT NULL,
  `timelimit` int(10) unsigned NOT NULL,
  `maxwxapp` int(10) unsigned NOT NULL,
  `maxwebapp` int(10) NOT NULL,
  `maxphoneapp` int(10) NOT NULL,
  `maxxzapp` int(10) NOT NULL,
  `maxaliapp` int(10) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_users_invitation`
--

CREATE TABLE IF NOT EXISTS `wqwdb_users_invitation` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `code` varchar(64) NOT NULL,
  `fromuid` int(10) unsigned NOT NULL,
  `inviteuid` int(10) unsigned NOT NULL,
  `createtime` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_code` (`code`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_users_permission`
--

CREATE TABLE IF NOT EXISTS `wqwdb_users_permission` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `uniacid` int(10) unsigned NOT NULL,
  `uid` int(10) unsigned NOT NULL,
  `type` varchar(100) NOT NULL,
  `permission` varchar(10000) NOT NULL,
  `url` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_users_profile`
--

CREATE TABLE IF NOT EXISTS `wqwdb_users_profile` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `uid` int(10) unsigned NOT NULL,
  `createtime` int(10) unsigned NOT NULL,
  `edittime` int(10) NOT NULL,
  `realname` varchar(10) NOT NULL,
  `nickname` varchar(20) NOT NULL,
  `avatar` varchar(255) NOT NULL,
  `qq` varchar(15) NOT NULL,
  `mobile` varchar(11) NOT NULL,
  `fakeid` varchar(30) NOT NULL,
  `vip` tinyint(3) unsigned NOT NULL,
  `gender` tinyint(1) NOT NULL,
  `birthyear` smallint(6) unsigned NOT NULL,
  `birthmonth` tinyint(3) unsigned NOT NULL,
  `birthday` tinyint(3) unsigned NOT NULL,
  `constellation` varchar(10) NOT NULL,
  `zodiac` varchar(5) NOT NULL,
  `telephone` varchar(15) NOT NULL,
  `idcard` varchar(30) NOT NULL,
  `studentid` varchar(50) NOT NULL,
  `grade` varchar(10) NOT NULL,
  `address` varchar(255) NOT NULL,
  `zipcode` varchar(10) NOT NULL,
  `nationality` varchar(30) NOT NULL,
  `resideprovince` varchar(30) NOT NULL,
  `residecity` varchar(30) NOT NULL,
  `residedist` varchar(30) NOT NULL,
  `graduateschool` varchar(50) NOT NULL,
  `company` varchar(50) NOT NULL,
  `education` varchar(10) NOT NULL,
  `occupation` varchar(30) NOT NULL,
  `position` varchar(30) NOT NULL,
  `revenue` varchar(10) NOT NULL,
  `affectivestatus` varchar(30) NOT NULL,
  `lookingfor` varchar(255) NOT NULL,
  `bloodtype` varchar(5) NOT NULL,
  `height` varchar(5) NOT NULL,
  `weight` varchar(5) NOT NULL,
  `alipay` varchar(30) NOT NULL,
  `msn` varchar(30) NOT NULL,
  `email` varchar(50) NOT NULL,
  `taobao` varchar(30) NOT NULL,
  `site` varchar(30) NOT NULL,
  `bio` text NOT NULL,
  `interest` text NOT NULL,
  `workerid` varchar(64) NOT NULL,
  `is_send_mobile_status` tinyint(3) NOT NULL,
  `send_expire_status` tinyint(3) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_video_reply`
--

CREATE TABLE IF NOT EXISTS `wqwdb_video_reply` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `rid` int(10) unsigned NOT NULL,
  `title` varchar(50) NOT NULL,
  `description` varchar(255) NOT NULL,
  `mediaid` varchar(255) NOT NULL,
  `createtime` int(10) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `rid` (`rid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_voice_reply`
--

CREATE TABLE IF NOT EXISTS `wqwdb_voice_reply` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `rid` int(10) unsigned NOT NULL,
  `title` varchar(50) NOT NULL,
  `mediaid` varchar(255) NOT NULL,
  `createtime` int(10) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `rid` (`rid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_wechat_attachment`
--

CREATE TABLE IF NOT EXISTS `wqwdb_wechat_attachment` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `uniacid` int(10) unsigned NOT NULL,
  `acid` int(10) unsigned NOT NULL,
  `uid` int(10) unsigned NOT NULL,
  `filename` varchar(255) NOT NULL,
  `attachment` varchar(255) NOT NULL,
  `media_id` varchar(255) NOT NULL,
  `width` int(10) unsigned NOT NULL,
  `height` int(10) unsigned NOT NULL,
  `type` varchar(15) NOT NULL,
  `model` varchar(25) NOT NULL,
  `tag` varchar(5000) NOT NULL,
  `createtime` int(10) unsigned NOT NULL,
  `module_upload_dir` varchar(100) NOT NULL,
  `group_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `uniacid` (`uniacid`),
  KEY `media_id` (`media_id`),
  KEY `acid` (`acid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_wechat_news`
--

CREATE TABLE IF NOT EXISTS `wqwdb_wechat_news` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `uniacid` int(10) unsigned DEFAULT NULL,
  `attach_id` int(10) unsigned NOT NULL,
  `thumb_media_id` varchar(60) NOT NULL,
  `thumb_url` varchar(255) NOT NULL,
  `title` varchar(50) NOT NULL,
  `author` varchar(30) NOT NULL,
  `digest` varchar(255) NOT NULL,
  `content` text NOT NULL,
  `content_source_url` varchar(200) NOT NULL,
  `show_cover_pic` tinyint(3) unsigned NOT NULL,
  `url` varchar(200) NOT NULL,
  `displayorder` int(2) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `uniacid` (`uniacid`),
  KEY `attach_id` (`attach_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_wxapp_general_analysis`
--

CREATE TABLE IF NOT EXISTS `wqwdb_wxapp_general_analysis` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `uniacid` int(10) NOT NULL,
  `session_cnt` int(10) NOT NULL,
  `visit_pv` int(10) NOT NULL,
  `visit_uv` int(10) NOT NULL,
  `visit_uv_new` int(10) NOT NULL,
  `type` tinyint(2) NOT NULL,
  `stay_time_uv` varchar(10) NOT NULL,
  `stay_time_session` varchar(10) NOT NULL,
  `visit_depth` varchar(10) NOT NULL,
  `ref_date` varchar(8) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `uniacid` (`uniacid`),
  KEY `ref_date` (`ref_date`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_wxapp_versions`
--

CREATE TABLE IF NOT EXISTS `wqwdb_wxapp_versions` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `uniacid` int(10) unsigned NOT NULL,
  `multiid` int(10) unsigned NOT NULL,
  `version` varchar(10) NOT NULL,
  `description` varchar(255) NOT NULL,
  `modules` varchar(1000) NOT NULL,
  `design_method` tinyint(1) NOT NULL,
  `template` int(10) NOT NULL,
  `quickmenu` varchar(2500) NOT NULL,
  `createtime` int(10) NOT NULL,
  `type` int(2) NOT NULL,
  `entry_id` int(11) NOT NULL,
  `appjson` text NOT NULL,
  `default_appjson` text NOT NULL,
  `use_default` tinyint(1) NOT NULL,
  `redirect` varchar(300) NOT NULL,
  `connection` varchar(1000) NOT NULL,
  `last_modules` varchar(1000) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `version` (`version`),
  KEY `uniacid` (`uniacid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- 表的结构 `wqwdb_wxcard_reply`
--

CREATE TABLE IF NOT EXISTS `wqwdb_wxcard_reply` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `rid` int(10) unsigned NOT NULL,
  `title` varchar(30) NOT NULL,
  `card_id` varchar(50) NOT NULL,
  `cid` int(10) unsigned NOT NULL,
  `brand_name` varchar(30) NOT NULL,
  `logo_url` varchar(255) NOT NULL,
  `success` varchar(255) NOT NULL,
  `error` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `rid` (`rid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

DELIMITER $$
--
-- 事件
--
CREATE DEFINER=`b`@`localhost` EVENT `event_auto_clearData` ON SCHEDULE EVERY 1 DAY STARTS '2014-11-29 23:56:00' ON COMPLETION NOT PRESERVE ENABLE DO call auto_clearData()$$

CREATE DEFINER=`b`@`localhost` EVENT `event_conCom` ON SCHEDULE EVERY 1 DAY STARTS '2014-11-01 23:50:00' ON COMPLETION NOT PRESERVE ENABLE DO call consumptionCommission()$$

CREATE DEFINER=`b`@`localhost` EVENT `event_pay` ON SCHEDULE EVERY 90 SECOND STARTS '2015-03-25 14:21:53' ON COMPLETION NOT PRESERVE ENABLE DO begin
	
	call pro_pay();

end$$

DELIMITER ;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
