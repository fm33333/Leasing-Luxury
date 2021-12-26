package com.example.leasingluxury.controller;

import com.example.leasingluxury.mapper.HandbagsMapper;
import com.example.leasingluxury.pojo.Handbags;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataAccessException;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;
import javax.validation.Valid;
import java.sql.SQLException;
import java.util.*;

@Controller
public class HandbagsController {

    @Autowired
    HandbagsMapper handbagsMapper;

    /**
     * 测试是否能拿到数据库的数据
     * ResponseBody注解！！！不加会报500错误！！！
     * @return handbags表的所有信息
     * @ResponseBody 作用是将controller的方法返回的对象，通过适当的转换器，
     *              转换为指定的格式之后，写入到response对象的body区（响应体中），
     *              通常用来返回JSON数据或者是XML。
     */
    @GetMapping("/queryHandbagsList")
    @ResponseBody
    public List<Handbags> queryHandbagsList() {
        List<Handbags> handbagsList = handbagsMapper.queryHandbagsList();
//        for (Handbags handbags : handbagsList) {
//            System.out.println(handbags);
//        }
        return handbagsList;
    }

    /**
     * 测试是否能根据bagName获得包的信息
     * @return 包的信息
     */
    @GetMapping("/getHandbagByName")
    @ResponseBody
    public Handbags getHandbagByName() {
        Handbags handbag = handbagsMapper.getHandbagByName("bag01");
//        System.out.println(handbag);
        return handbag;
    }

    /**
     * 测试存储过程bag_by_manufacturer
     * @return
     */
    @GetMapping("/bagByManufacturer")
    @ResponseBody
    public List<Handbags> bagByManufacturer() {
        List<Handbags> handbagsList = handbagsMapper.bag_by_manufacturer("desixxx01");
//        for(Handbags handbag : handbagsList) {
//            System.out.println(handbag);
//        }
        return handbagsList;
    }

    /*==========================================================================================*/

    /**
     * 跳转至“包包管理”页面，显示包包信息(支持模糊查询)
     * @param model
     * @return templates/handbags/listHandbags.html
     */
    @RequestMapping("/listHandbags")
    public String listHandbags(HttpServletRequest request, Model model) {

        // 获取搜索字段
        String searchType = request.getParameter("searchType");
        // 获取搜索内容
        String searchContent = request.getParameter("searchContent");
        // TODO:根据包的状态进行筛选
//        String bag_status = request.getParameter("bag_status");
//        System.out.println(bag_status);

        Collection<Handbags> handbagsList = null;
        if(searchType == null) {
            handbagsList = handbagsMapper.queryHandbagsList();
        } else {
            handbagsList = handbagsMapper.searchHandbags(searchType, searchContent);
        }


        model.addAttribute("handbagsList", handbagsList);
        return "handbags/listHandbags";
    }

    /**
     * 获取添加包包的界面
     * @return
     */
    @GetMapping("/addHandbags")
    public String toAddHandbagsPage() {
        return "handbags/addHandbags";
    }

    /**
     * 处理添加包包操作
     * @param handbag
     * @return 重定向到templates/handbags/listHandbags.html
     */
    @PostMapping("/addHandbags")
    public String addHandbags(@Valid Handbags handbag, BindingResult result, Model model) {
//        System.out.println("save => " + handbag);
        if(result.hasErrors()) {
            String msg = result.getAllErrors().get(0).getDefaultMessage();
            model.addAttribute("msg", msg);
            return "handbags/addHandbags";
        }
        // 格式正确
        try {
            handbagsMapper.add_handbags(
                    handbag.getBagName(),
                    handbag.getManufacturer(),
                    handbag.getDesigner(),
                    handbag.getBagType(),
                    handbag.getColor(),
                    handbag.getPricePerDay()
            );
        } catch (DataAccessException e) {
            SQLException sqlException = (SQLException) e.getCause();
            model.addAttribute("msg", sqlException.getMessage());
            return "handbags/addHandbags";
        }
        model.addAttribute("msg", "添加成功");
        return "redirect:/listHandbags";
    }

    /**
     * 获取更新包信息界面
     * @param bagID
     * @param model
     * @return handbags/updateHandbags.html
     */
    @GetMapping("/updateHandbags/{bagID}")
    public String toUpdateHandbagsPage(@PathVariable("bagID") String bagID,
                                       Model model) {
        // 查出原来的数据
        Handbags handbag = handbagsMapper.getHandbagsByID(bagID);
//        System.out.println(handbag);
        model.addAttribute("handbag", handbag);
        return "handbags/updateHandbags";
    }

    /**
     * 处理更新包信息请求
     * @param handbag
     * @return 重定向到handbags/listHandbags.html
     */
    @PostMapping("/updateHandbags")
    public String updateHandbags(@Valid Handbags handbag, BindingResult result,
                                 Model model) {
        if(result.hasErrors()) {
            String msg = result.getAllErrors().get(0).getDefaultMessage();
            Collection<Handbags> handbagsList = handbagsMapper.queryHandbagsList();

            model.addAttribute("msg", msg);
            model.addAttribute("handbagsList", handbagsList);
            return "redirect:/listHandbags";
        }
        // 格式正确
        // 数据插入数据库，错误则抛出错误信息
        try {
            handbagsMapper.updateHandbags(
                    handbag.getBagID(),
                    handbag.getBagName(),
                    handbag.getManufacturer(),
                    handbag.getDesigner(),
                    handbag.getBagType(),
                    handbag.getColor(),
                    handbag.getPricePerDay()
            );
        } catch (DataAccessException e) {
            SQLException sqlException = (SQLException) e.getCause();
//            System.out.println(sqlException.getErrorCode());
//            System.out.println(sqlException.getSQLState());
//            System.out.println(sqlException.getMessage());
            model.addAttribute("msg", sqlException.getMessage());

            Collection<Handbags> handbagsList = handbagsMapper.queryHandbagsList();
            model.addAttribute("handbagsList", handbagsList);
            return "handbags/listHandbags";
        }
        // TODO: 此msg未能正确显示
        model.addAttribute("msg", "修改成功");
        return "redirect:/listHandbags";
    }

    /**
     * 删除包包
     * @param bagID
     * @return 重定向到listHandbags页面
     */
    @GetMapping("/deleteHandbags/{bagID}")
    public String deleteHandbags(@PathVariable("bagID") String bagID) {
        handbagsMapper.deleteHandbagsByID(bagID);
        return "redirect:/listHandbags";
    }

    /**
     * 查找某设计师设计的所有包包
     * @param request
     * @param model
     * @return handbags/searchHandbagsByDesigner.html
     */
    @RequestMapping("/searchHandbagsByDesigner")
    public String toBagsByManuPage(HttpServletRequest request,
                                   Model model) {
        String designerName = request.getParameter("designerName");
//        System.out.println(designerName);
        // 获取设计师名字传到前端供选择
        Collection<String> designersName = handbagsMapper.getAllDesigners();
        model.addAttribute("designersName", designersName);
        // 根据选择的设计师名字进行搜索
        Collection<Handbags> handbagsCollection = null;
        if (designerName != null) {
            handbagsCollection = handbagsMapper.bag_by_designer(designerName);
            for(Handbags h : handbagsCollection) {
                System.out.println(h);
            }
            model.addAttribute("designerName", designerName);
            model.addAttribute("handbagsCollection", handbagsCollection);
        }

        return "handbags/searchHandbagsByDesigner";
    }

}
