package com.example.leasingluxury.controller;

import com.example.leasingluxury.dao.DepartmentDao;
import com.example.leasingluxury.dao.EmployeeDao;
import com.example.leasingluxury.pojo.Department;
import com.example.leasingluxury.pojo.Employee;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.Collection;

@Controller
public class EmployeeController {

    @Autowired
    EmployeeDao employeeDao;
    @Autowired
    DepartmentDao departmentDao;

    @RequestMapping("/emps")
    public String list(Model model) {
        Collection<Employee> employees = employeeDao.getAll();
        model.addAttribute("emps", employees);
        return "emp/list";
    }

    @GetMapping("/addEmp")
    public String toAddEmpPage(Model model) {
        //查出部门的信息
        Collection<Department> departments = departmentDao.getDepartments();
        model.addAttribute("departments", departments);
        return "emp/addEmp"; //templates中的路径
    }

    @PostMapping("/addEmp")
    public String addEmp(Employee employee) {
        System.out.println("save=>" + employee);
        //添加的操作
        employeeDao.save(employee); //调用底层业务方法保存员工信息
        return "redirect:/emps";
    }

    @GetMapping("/update/{id}")
    public String toUpdateEmpPage(@PathVariable("id") Integer id, Model model) {
        //修改员工数据
        //查出原来数据
        Employee employee = employeeDao.getEmployeeById(id);
        model.addAttribute("emp", employee);
        //查出所有部门信息
        Collection<Department> departments = departmentDao.getDepartments();
        model.addAttribute("departments", departments);
        return "emp/updateEmp";
    }

    @PostMapping("/updateEmp")
    public String updateEmp(Employee employee) {
        employeeDao.save(employee);
        return "redirect:/emps";
    }

    @GetMapping("/delete/{id}")
    public String deleteEmp(@PathVariable("id") Integer id) {
        employeeDao.deleteEmployeeById(id);
        return "redirect:/emps";
    }
}
