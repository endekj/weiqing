<?php defined('IN_IA') or exit('Access Denied');?></div>
<div class="container-fluid footer text-center" role="footer">
	<div class="copyright">Powered by <a href="http://b.heicat.com"><b>虎王%博客</b></a>&copy; 2014-2019 <a>欢迎使用-微擎-稳定版</a></div>
	<?php  if(!empty($_W['setting']['copyright']['icp'])) { ?><div>备案号：<a href="http://www.miitbeian.gov.cn" target="_blank"><?php  echo $_W['setting']['copyright']['icp'];?></a></div><?php  } ?>
</div>
<?php  if(!empty($_W['setting']['copyright']['statcode'])) { ?><?php  echo $_W['setting']['copyright']['statcode'];?><?php  } ?>
<?php  if(!empty($_GPC['m']) && !in_array($_GPC['m'], array('keyword', 'special', 'welcome', 'default', 'userapi')) || defined('IN_MODULE')) { ?>
<script>
	if(typeof $.fn.tooltip != 'function' || typeof $.fn.tab != 'function' || typeof $.fn.modal != 'function' || typeof $.fn.dropdown != 'function') {
		require(['bootstrap']);
	}
</script>
<?php  } ?>
</div>

<script type="text/javascript" src="<?php  echo $_W['siteroot'];?>web/index.php?c=utility&a=visit&do=showjs&type=<?php echo FRAME;?>"></script>

</body>
</html>
