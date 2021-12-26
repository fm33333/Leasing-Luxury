package com.example.leasingluxury.controller;

import com.example.leasingluxury.mapper.CustomersMapper;
import com.example.leasingluxury.mapper.HandbagsMapper;
import com.example.leasingluxury.mapper.RentalsMapper;
import com.example.leasingluxury.pojo.Customers;
import com.example.leasingluxury.pojo.Handbags;
import com.example.leasingluxury.pojo.Rentals;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataAccessException;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import javax.servlet.http.HttpServletRequest;
import javax.validation.Valid;
import java.sql.SQLException;
import java.util.Collection;
import java.util.List;
import java.util.Map;

@Controller
public class RentalsController {

    @Autowired
    RentalsMapper rentalsMapper;
    @Autowired
    CustomersMapper customersMapper;
    @Autowired
    HandbagsMapper handbagsMapper;

    /**
     * 获取显示租赁信息的界面
     * @param request
     * @param model
     * @return templates/rentals/listRentals.html
     */
    @RequestMapping("/listRentals")
    public String listRentals(HttpServletRequest request,
                              Model model) {
        String resEmpty = "";
        // 获取搜索分类
        String searchType = request.getParameter("searchType");
        // 获取搜索内容
        String searchContent = request.getParameter("searchContent");

        Collection<Rentals> rentalsCollection = null;
        if(searchType == null) {
            rentalsCollection = rentalsMapper.queryRentalsList();
        } else {
            rentalsCollection = rentalsMapper.searchRentals(searchType, searchContent);
            // 搜索结果为空
            if(rentalsCollection.isEmpty()) {
                resEmpty = "无搜索结果";
                model.addAttribute("resEmpty", resEmpty);
            }
        }

        model.addAttribute("rentalsCollection", rentalsCollection);
        model.addAttribute("customersMapper", customersMapper);
        model.addAttribute("handbagsMapper", handbagsMapper);
        return "rentals/listRentals";
    }

    /**
     * 获取租赁宝宝的页面，并将所有客户和在库的包包传过去供选择
     * @param model
     * @return templates/rentals/addRentals
     */
    @GetMapping("/addRentals")
    public String toAddRentalsPage(Model model) {
        Collection<Customers> customersCollection = customersMapper.queryCustomersList();
        model.addAttribute("customersCollection", customersCollection);
        Collection<Handbags> handbagsCollection = handbagsMapper.searchHandbags("bagStatus", "0");
        model.addAttribute("handbagsCollection", handbagsCollection);
        return "rentals/addRentals";
    }

    /**
     * 处理租赁包包的操作，格式错误则提示相应的错误
     * @param rentals
     * @param result
     * @param model
     * @return templates/rentals/listRentals
     */
    @PostMapping("/addRentals")
    public String addRentals(@Valid Rentals rentals, BindingResult result,
                             Model model) {
        String msg = "";
        if(result.hasErrors()) {
            msg = result.getAllErrors().get(0).getDefaultMessage();
//            System.out.println(msg);
            model.addAttribute("msg", msg);
            Collection<Customers> customersCollection = customersMapper.queryCustomersList();
            model.addAttribute("customersCollection", customersCollection);
            Collection<Handbags> handbagsCollection = handbagsMapper.searchHandbags("bagStatus", "0");
            model.addAttribute("handbagsCollection", handbagsCollection);
            return "rentals/addRentals";
        }
        // 格式正确
        // 插入数据库，若失败则抛出异常
        try {
            rentalsMapper.add_rentals(
                    rentals.getCustomerID(),
                    rentals.getBagID(),
                    rentals.getDateRented(),
                    rentals.getDateReturned(),
                    rentals.getInsurance()
            );
        } catch (DataAccessException e) {
            SQLException sqlException = (SQLException) e.getCause();
            model.addAttribute("msg", sqlException.getMessage());
        }

        msg = "租赁成功";
        model.addAttribute("msg", msg);
        return "redirect:/listRentals";
    }

    /**
     * 归还包包操作
     * @param rentalID
     * @param model
     * @return templates/rentals/returnHandbagsInfo
     */
    @GetMapping("/returnHandbags/{rentalID}")
    public String toReturnHandbagsPage(@PathVariable("rentalID") String rentalID,
                                       Model model) {
//        System.out.println("customerID:" + customerID + " bagID:" + bagID);
        // 修改归还状态并获取该次租赁天数
        Integer totalLengthOfRental = rentalsMapper.report_info_afterReturned(rentalID);
        // 获取该次租赁金额
        Double totalPriceOfRental = rentalsMapper.report_info2_afterReturned(rentalID);
//        System.out.println(totalLengthOfRental);
//        System.out.println(totalPriceOfRental);
        Rentals rental = rentalsMapper.getRentalByID(rentalID);
        String firstName = customersMapper.getCustomerFirstNameByID(rental.getCustomerID());
        String lastName = customersMapper.getCustomerLastNameByID(rental.getCustomerID());
        String bagName = handbagsMapper.getHandbagNameByID(rental.getBagID());

        model.addAttribute("totalLengthOfRental", totalLengthOfRental);
        model.addAttribute("totalPriceOfRental", totalPriceOfRental);
        // TODO:可以只传一个Customers对象
        model.addAttribute("firstName", firstName);
        model.addAttribute("lastName", lastName);
        model.addAttribute("bagName", bagName);
        return "rentals/returnHandbagsInfo";
    }

    /**
     * 删除交易记录
     * @param rentalID
     * @param model
     * @return 重定向templates/rentals/listRentals.html
     */
    @GetMapping("/deleteRentals/{rentalID}")
    public String deleteRentals(@PathVariable("rentalID") String rentalID,
                                Model model) {
        Rentals rental = rentalsMapper.getRentalByID(rentalID);
        // 未归还的交易记录不能删
        if(rental.getReturnStatus() == 0) {
            // 此msg无法正确传到前端
            String msg = "包包未归还，不可删除";
            model.addAttribute("msg", msg);
        } else {
            rentalsMapper.deleteRentals(rentalID);
            model.addAttribute("msg", null);
        }
        return "redirect:/listRentals";

    }

}
