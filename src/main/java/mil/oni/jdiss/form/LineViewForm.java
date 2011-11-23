package mil.oni.jdiss.form;

import org.apache.struts.action.ActionForm;

public class LineViewForm extends ActionForm{
	
	private static final long serialVersionUID = 1L;
	
	String message;

	
	public String getMessage() {
		return message;
	}

	public void setMessage(String message) {
		this.message = message;
	}
}