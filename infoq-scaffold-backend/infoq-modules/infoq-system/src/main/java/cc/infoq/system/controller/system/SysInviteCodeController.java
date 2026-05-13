package cc.infoq.system.controller.system;

import cc.infoq.common.constant.SystemConstants;
import cc.infoq.common.domain.ApiResult;
import cc.infoq.common.excel.utils.ExcelUtil;
import cc.infoq.common.log.annotation.Log;
import cc.infoq.common.log.enums.BusinessType;
import cc.infoq.common.mybatis.core.page.PageQuery;
import cc.infoq.common.mybatis.core.page.TableDataInfo;
import cc.infoq.common.redis.annotation.RepeatSubmit;
import cc.infoq.common.validate.AddGroup;
import cc.infoq.common.validate.EditGroup;
import cc.infoq.common.web.core.BaseController;
import cc.infoq.system.domain.bo.SysInviteCodeBo;
import cc.infoq.system.domain.vo.SysInviteCodeVo;
import cc.infoq.system.service.SysInviteCodeService;
import cn.dev33.satoken.annotation.SaCheckPermission;
import cn.dev33.satoken.annotation.SaCheckRole;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.validation.constraints.NotEmpty;
import lombok.AllArgsConstructor;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 邀请码管理
 *
 * @author Pontus
 */
@Validated
@AllArgsConstructor
@RestController
@RequestMapping("/system/invite")
public class SysInviteCodeController extends BaseController {

    private final SysInviteCodeService sysInviteCodeService;

    /**
     * 查询邀请码列表
     */
    @SaCheckRole(SystemConstants.SUPER_ADMIN_ROLE_KEY)
    @SaCheckPermission("system:invite:list")
    @GetMapping("/list")
    public TableDataInfo<SysInviteCodeVo> list(SysInviteCodeBo bo, PageQuery pageQuery) {
        return sysInviteCodeService.queryPageList(bo, pageQuery);
    }

    /**
     * 导出邀请码列表
     */
    @SaCheckRole(SystemConstants.SUPER_ADMIN_ROLE_KEY)
    @SaCheckPermission("system:invite:export")
    @Log(title = "邀请码管理", businessType = BusinessType.EXPORT)
    @PostMapping("/export")
    public void export(SysInviteCodeBo bo, HttpServletResponse response) {
        List<SysInviteCodeVo> list = sysInviteCodeService.queryList(bo);
        ExcelUtil.exportExcel(list, "邀请码数据", SysInviteCodeVo.class, response);
    }

    /**
     * 生成邀请码
     */
    @SaCheckRole(SystemConstants.SUPER_ADMIN_ROLE_KEY)
    @SaCheckPermission("system:invite:add")
    @Log(title = "邀请码管理", businessType = BusinessType.INSERT)
    @RepeatSubmit
    @PostMapping("/generate")
    public ApiResult<Void> generate(@Validated(AddGroup.class) @RequestBody SysInviteCodeBo bo) {
        return toAjax(sysInviteCodeService.generateInviteCodes(bo));
    }

    /**
     * 作废邀请码
     */
    @SaCheckRole(SystemConstants.SUPER_ADMIN_ROLE_KEY)
    @SaCheckPermission("system:invite:edit")
    @Log(title = "邀请码管理", businessType = BusinessType.UPDATE)
    @RepeatSubmit
    @PutMapping("/cancel")
    public ApiResult<Void> cancel(@Validated(EditGroup.class) @RequestBody SysInviteCodeBo bo) {
        return toAjax(sysInviteCodeService.cancelInviteCode(bo));
    }

    /**
     * 删除邀请码
     *
     * @param inviteIds 邀请码ID串
     */
    @SaCheckRole(SystemConstants.SUPER_ADMIN_ROLE_KEY)
    @SaCheckPermission("system:invite:remove")
    @Log(title = "邀请码管理", businessType = BusinessType.DELETE)
    @DeleteMapping("/{inviteIds}")
    public ApiResult<Void> remove(@NotEmpty(message = "邀请码ID不能为空") @PathVariable Long[] inviteIds) {
        return toAjax(sysInviteCodeService.deleteWithValidByIds(List.of(inviteIds)));
    }
}
