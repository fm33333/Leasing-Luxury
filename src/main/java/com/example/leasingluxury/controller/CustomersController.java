package com.example.leasingluxury.controller;

import com.example.leasingluxury.mapper.CustomersMapper;
import com.example.leasingluxury.pojo.AmountInfo;
import com.example.leasingluxury.pojo.Customers;
import com.example.leasingluxury.pojo.Handbags;
import org.apache.ibatis.jdbc.SQL;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataAccessException;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.ui.ModelMap;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import javax.servlet.http.HttpServletRequest;
import javax.validation.Valid;
import java.sql.SQLException;
import java.util.Collection;

@Controller
public class CustomersController {

    @Autowired
    CustomersMapper customersMapper;

    /**
     * 跳转至“客户管理”页面，显示客户信息
     * HttpServletRequest获取搜索内容，进行模糊查询
     * @param request
     * @param model
     * @return templates/customers/listCustomers.html
     */
    @RequestMapping("/listCustomers")
    public String listCustomers(HttpServletRequest request, Model model) {

        // 获取搜索分类
        String searchType = request.getParameter("searchType");
        // 获取搜索内容
        String searchContent = request.getParameter("searchContent");

        Collection<Customers> customersCollection = null;
        if(searchType == null) {
            customersCollection = customersMapper.queryCustomersList();
        } else {
            customersCollection = customersMapper.searchCustomers(searchType, searchContent);
        }

        model.addAttribute("customerCollection", customersCollection);
        return "customers/listCustomers";
    }

    /**
     * 获取添加客户的界面
     * @return templates/customers/addCustomers.html
     */
    @GetMapping("/addCustomers")
    public String toAddCustomersPage() {
        return "customers/addCustomers";
    }

    /**
     * 处理添加客户操作
     * @param customer
     * @return templates/customers/listCustomers.html
     */
    @PostMapping("/addCustomers")
    public String addCustomers(@Valid Customers customer, BindingResult result,
                               Model model) {
        String msg = "";
        // @Valid注解判断customer格式是否有错
        if(result.hasErrors()) {
            msg = result.getAllErrors().get(0).getDefaultMessage();
            System.out.println(msg);
            return "customers/addCustomers";
        }
        // 格式正确
        // 插入数据库，若失败则抛出异常
        try {
            customersMapper.add_customers(
                    customer.getFirstName(),
                    customer.getLastName(),
                    customer.getPhone(),
                    customer.getAddress(),
                    customer.getEmailAddr(),
                    customer.getCreditCardID()
            );
        } catch (DataAccessException e) {
            SQLException sqlException = (SQLException) e.getCause();
//            System.out.println(sqlException.getErrorCode());
//            System.out.println(sqlException.getSQLState());
//            System.out.println(sqlException.getMessage());
            model.addAttribute("msg", sqlException.getMessage());
            return "customers/addCustomers";
        }

        msg = "添加成功";
        model.addAttribute("msg", msg);
        return "redirect:/listCustomers";
    }

    /**
     * 跳转至更新客户信息界面
     * @param customerID
     * @param model
     * @return templates/customers/updateCustomers.html
     */
    @GetMapping("/updateCustomers/{customerID}")
    public String toUpdateCustomersPage(@PathVariable("customerID") String customerID,
                                        Model model) {
        // 查出原来的数据
        Customers customer = customersMapper.getCustomerByID(customerID);
        model.addAttribute("customer", customer);
        return "customers/updateCustomers";
    }

    /**
     * 处理更新客户信息操作
     * @param customer
     * @param result
     * @param model
     * @return templates/customers/listCustomers.html
     */
    @PostMapping("/updateCustomers")
    public String updateCustomers(@Valid Customers customer, BindingResult result,
                                  Model model) {
        if(result.hasErrors()) {
            String msg = result.getAllErrors().get(0).getDefaultMessage();
            Collection<Customers> customersCollection = customersMapper.queryCustomersList();

            model.addAttribute("msg", msg);
            model.addAttribute("customerCollection", customersCollection);
            return "customers/listCustomers";
        }
        // 格式正确
        try {
            customersMapper.updateCustomers(
                    customer.getCustomerID(),
                    customer.getFirstName(),
                    customer.getLastName(),
                    customer.getPhone(),
                    customer.getAddress(),
                    customer.getEmailAddr(),
                    customer.getCreditCardID()
            );
        } catch (DataAccessException e) {
            SQLException sqlException = (SQLException) e.getCause();
//            System.out.println(sqlException.getErrorCode());
//            System.out.println(sqlException.getSQLState());
//            System.out.println(sqlException.getMessage());
            model.addAttribute("msg", sqlException.getMessage());

            Collection<Customers> customersCollection = customersMapper.queryCustomersList();
            model.addAttribute("customerCollection", customersCollection);
            return "customers/listCustomers";
        }
        model.addAttribute("msg", "修改成功");
        return "redirect:/listCustomers";
    }

    /**
     * 删除客户信息
     * @param customerID
     * @return 返回listCustomers页面
     */
    @GetMapping("/deleteCustomers/{customerID}")
    public String deleteCustomers(@PathVariable("customerID") String customerID) {
        customersMapper.deleteCustomersByID(customerID);
        return "redirect:/listCustomers";
    }

    /**
     * 跳转到best customers页面，将客户按总租赁天数降序排序
     * @param model
     * @return templates/customers/getBestCustomers.html
     */
    @GetMapping("/getBestCustomers")
    public String toBestCustomersPage(Model model) {
        Collection<Customers> customersCollection = customersMapper.best_customers();
        model.addAttribute("customersCollection", customersCollection);
        return "customers/getBestCustomers";
    }

    /**
     * 显示指定客户的消费信息
     * @param request
     * @param model
     * @return templates/customers/reportCustomerAmount.html
     */
    @RequestMapping("/reportCustomerAmount")
    public String toReportCustomerAmountPage(HttpServletRequest request,
                                             Model model) {

        String customerID = request.getParameter("customerID");
        System.out.println(customerID);
        // 向前端传数据，用以显示客户名字，供选择进行搜索
        Collection<Customers> customersCollection = customersMapper.queryCustomersList();
        model.addAttribute("customersCollection", customersCollection);

        Customers customer = customersMapper.getCustomerByID(customerID);
        model.addAttribute("customer", customer);

        // 查询数据
        Collection<AmountInfo> amountInfos = customersMapper.report_customer_amount(customerID);
        // 计算租赁的所有包包的总金额
        Double amountSum = 0.0;
        if(!amountInfos.isEmpty()) {
            model.addAttribute("amountInfos", amountInfos);

            for(AmountInfo a : amountInfos) {
                amountSum += a.getAmount();
            }
            System.out.println(amountSum);
            model.addAttribute("amountSum", amountSum);
        } else {
            model.addAttribute("msg", "无消费信息");
        }
        return "customers/reportCustomerAmount";
    }
}
