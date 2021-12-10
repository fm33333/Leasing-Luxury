package com.example.leasingluxury.dao;

import com.example.leasingluxury.pojo.Employee;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import java.util.Collection;
import java.util.HashMap;
import java.util.Map;

@Repository
public class EmployeeDao {

    //模拟数据库中的数据
    private static Map<Integer, Employee> employees = null;

    @Autowired
    private static DepartmentDao departmentDao;

    static {
        employees = new HashMap<Integer, Employee>(); //创建一个表

        employees.put(1001, new Employee(1001, "AA", "A123@qq.com", 0, departmentDao.getDepartmentById(101)));
        employees.put(1002, new Employee(1002, "BB", "B123@qq.com", 1, departmentDao.getDepartmentById(102)));
        employees.put(1003, new Employee(1003, "CC", "C123@qq.com", 0, departmentDao.getDepartmentById(103)));
        employees.put(1004, new Employee(1004, "DD", "D123@qq.com", 1, departmentDao.getDepartmentById(104)));
        employees.put(1005, new Employee(1005, "EE", "E123@qq.com", 0, departmentDao.getDepartmentById(105)));
    }

    //主键自增
    private static Integer initID = 1006;
    //增加员工
    public void save(Employee employee) {
        if(employee.getEid() == null) {
            employee.setEid(initID++);
        }

        employee.setDepartment(departmentDao.getDepartmentById(employee.getDepartment().getId()));
        employees.put(employee.getEid(), employee);
    }

    //查询所有员工信息
    public Collection<Employee> getAll() {
        return employees.values();
    }

    //通过id查询员工
    public Employee getEmployeeById(Integer id) {
        return employees.get(id);
    }

    //通过id删除员工
    public void deleteEmployeeById(Integer id) {
        employees.remove(id);
    }
}
